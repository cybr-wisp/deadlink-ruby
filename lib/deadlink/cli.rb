
require "optparse"
require "benchmark"

module Deadlink
  class CLI
    def self.start(argv)
      new.run(argv)
    end

    def run(argv)
      options = { concurrency: 20, timeout: 2, verbose: false }

      OptionParser.new do |opts|
        opts.banner = "Usage: deadlink [directory] [options]"
        opts.on("--concurrency N", Integer, "Links checked simultaneously (default: 10)") { |n| options[:concurrency] = n }
        opts.on("--timeout N", Integer, "Per-request timeout in seconds (default: 5)") { |n| options[:timeout] = n }
        opts.on("--verbose", "Show all links checked, not just failures") { options[:verbose] = true }
      end.parse!(argv)

      directory = argv.first || "."
      unless Dir.exist?(directory)
        warn "Error: #{directory} is not a valid directory"
        exit 1
      end

      puts "Scanning #{directory} for Markdown files..."
      files = MarkdownParser.find_markdown_files(directory)
      links = MarkdownParser.extract_all_links(directory)
      puts "Found #{files.size} files, #{links.size} links total\n\n"

      checker = LinkChecker.new(concurrency: options[:concurrency], timeout: options[:timeout])
      results = nil
      elapsed = Benchmark.realtime { results = checker.check_all(links) }

      reporter = Reporter.new(results, verbose: options[:verbose])
      puts reporter.summary
      puts "\nDone in #{elapsed.round(2)}s"

      exit(reporter.any_broken? ? 1 : 0)
    end
  end
end