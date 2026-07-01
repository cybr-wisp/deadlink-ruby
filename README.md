
### Deadlink

A fast, concurrent Ruby CLI tool that scans project directories for Markdown files and validates every hyperlink inside them — flagging broken, unreachable, or malformed URLs before they ship in a README or documentation site.

## Why

Markdown files rot. Links move, repositories get renamed, documentation sites restructure — and nobody notices until a broken link ships in production. Deadlink catches these issues automatically, whether in CI or locally, before they become someone else's problem.

## Features

- **Recursive directory scanning** — point it at any folder, and it discovers every `.md` file underneath without manual file lists.
- **Dual link detection** — parses both standard Markdown links (`[text](url)`) and bare URLs typed directly in text.
- **Concurrent link checking** — validates multiple endpoints in parallel via a throttled thread pool, eliminating sequential bottlenecks.
- **Clear pass/fail reporting** — readable summaries showing what broke, where, and why (timeout, 404, connection refused, etc.).
- **Zero external dependencies** — runs entirely locally with no API keys or third-party services required.

## Installation

Clone the repository and install dependencies with Bundler:

```bash
git clone https://github.com/cybr-wisp/deadlink-ruby.git
cd deadlink-ruby
bundle install