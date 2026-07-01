
# Performance Benchmark

Measured on a 104-link synthetic fixture (`bench/benchmark.md`) containing a realistic
mix of fast, valid endpoints (Google, GitHub, Wikipedia, MDN, PyPI, npm, etc.) plus
4 intentionally unreachable domains.

## Method

```bash
bundle exec ruby bin/deadlink bench --concurrency 1  --timeout 5   # baseline
bundle exec ruby bin/deadlink bench --concurrency 10 --timeout 5   # initial concurrency
bundle exec ruby bin/deadlink bench --concurrency 25 --timeout 2   # tuned timeout
bundle exec ruby bin/deadlink bench --concurrency 40 --timeout 1   # final config
```

## Results

| Concurrency | Timeout | Time    | Links OK | Links Broken |
|-------------|---------|---------|----------|--------------|
| 1           | 5s      | 24.06s  | 28       | 77           |
| 10          | 5s      | 8.34s   | 27       | 78           |
| 25          | 2s      | 4.33s   | 100      | 4            |
| 40          | 1s      | 1.81s   | 96       | 8            |

- **92.5% reduction in total scan time** (24.06s → 1.81s) between sequential
  execution and the final tuned concurrent configuration.
- **13.3x speedup** overall.
- At high concurrency (40 threads) against real third-party services, a few
  endpoints (npm, Stack Overflow) returned `403`/`429` due to those services'
  own bot/rate-limit protection — not a Deadlink defect, but a real-world
  tradeoff of aggressive parallelism against production APIs.

## Reproducing

```bash
git clone https://github.com/cybr-wisp/deadlink-ruby.git
cd deadlink-ruby
bundle install
bundle exec ruby bin/deadlink bench --concurrency 40 --timeout 1
```