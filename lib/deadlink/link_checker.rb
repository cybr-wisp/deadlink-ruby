require "net/http"
require "uri"
require "concurrent"

module Deadlink
  class LinkChecker
    Result = Struct.new(:link, :status, :message, keyword_init: true)

    class TooManyRedirects < StandardError; end

    def initialize(concurrency: 10, timeout: 2)
      @concurrency = concurrency
      @timeout = timeout
    end

    def check_all(links)
      pool = Concurrent::FixedThreadPool.new(@concurrency)
      results = Concurrent::Array.new

      links.each do |link|
        pool.post { results << check_link(link) }
      end

      pool.shutdown
      pool.wait_for_termination
      results.to_a
    end

    private

    def check_link(link)
      uri = URI.parse(link.url)
      return Result.new(link: link, status: :invalid, message: "Malformed URL") unless uri.is_a?(URI::HTTP)

      response = fetch(uri)

      if response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
        Result.new(link: link, status: :ok, message: response.code)
      else
        Result.new(link: link, status: :broken, message: "#{response.code} #{response.message}")
      end
    rescue URI::InvalidURIError
      Result.new(link: link, status: :invalid, message: "Malformed URL")
    rescue Net::OpenTimeout, Net::ReadTimeout
      Result.new(link: link, status: :broken, message: "Timeout")
    rescue TooManyRedirects
      Result.new(link: link, status: :broken, message: "Too many redirects")
    rescue SocketError
      Result.new(link: link, status: :broken, message: "Could not resolve host")
    rescue StandardError => e
      Result.new(link: link, status: :broken, message: e.message || e.class.name)
    end

    def fetch(uri, redirect_limit: 5)
      raise TooManyRedirects if redirect_limit.zero?

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = @timeout
      http.read_timeout = @timeout

      path = uri.request_uri.nil? || uri.request_uri.empty? ? "/" : uri.request_uri

      response =
        begin
          http.request_head(path)
        rescue Net::HTTPBadResponse, NoMethodError
          # Some servers reject HEAD requests outright — fall back to GET
          http.request_get(path)
        end

      if response.is_a?(Net::HTTPRedirection) && response["location"]
        # Location headers can be relative ("/docs") or absolute — resolve
        # against the current URI so relative redirects don't produce a
        # host-less URI on the next hop.
        next_uri = uri.merge(response["location"])
        fetch(next_uri, redirect_limit: redirect_limit - 1)
      else
        response
      end
    end
  end
end