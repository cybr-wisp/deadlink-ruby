
require_relative "lib/deadlink/version"

Gem::Specification.new do |spec|
  spec.name        = "deadlink"
  spec.version      = Deadlink::VERSION
  spec.authors      = ["Marie Sindhu"]
  spec.summary      = "A CLI tool that scans Markdown files for broken hyperlinks"
  spec.description  = "Recursively scans a directory for Markdown files, extracts hyperlinks, " \
                       "and concurrently checks them for broken/dead endpoints."
  spec.homepage     = "https://github.com/cybr-wisp/deadlink-ruby"
  spec.license      = "MIT"
  spec.required_ruby_version = ">= 3.0"

  spec.files         = Dir["lib/**/*.rb", "bin/*", "README.md"]
  spec.bindir        = "bin"
  spec.executables    = ["deadlink"]
  spec.require_paths  = ["lib"]

  spec.add_dependency "concurrent-ruby", "~> 1.2"

  spec.add_development_dependency "minitest", "~> 5.20"
  spec.add_development_dependency "rake", "~> 13.0"
end