# Site Analytics and Capacity

Measured on 2026-08-19. Re-run the checks after large course imports or hosting changes.

## Hosting model and limits

The site is pre-built by Jekyll and served from GitHub Pages. There is no application server or database to size. Capacity is primarily constrained by the GitHub Pages CDN limits and the number of bytes served, rather than Ruby process concurrency.

GitHub currently documents these relevant limits:

- Published site size: 1 GB maximum.
- Bandwidth: 100 GB per month, soft limit.
- Deployment duration: 10 minutes maximum.
- Requests may be rate-limited with HTTP 429 during bursts.

GitHub does not publish a guaranteed concurrent-request limit for Pages. Do not stress-test the production `github.io` endpoint. Monitor 429 responses and move behind a separately controlled CDN before doing load tests.

## Current baseline

The production build contains 8,230 files and is 865.41 MiB (about 907 MB). That is about 90.7% of GitHub's documented 1 GB ceiling and 93.1% of this repository's 930 MiB deployment budget.

| Surface | Measured size |
| --- | ---: |
| Generated site | 865.41 MiB |
| `assets/courses` | 737.08 MiB |
| Rendered slide images | 308.00 MiB across 5,453 files |
| Median complete slide deck | 4.75 MiB |
| 90th-percentile slide deck | 7.15 MiB |
| Largest slide deck | 14.51 MiB |
| Median generated note HTML | 138.7 KiB uncompressed |
| 95th-percentile generated note HTML | 333.0 KiB uncompressed |

Cold-browser measurements count encoded bytes fetched from `jingzechen.github.io`; third-party CDN bytes are excluded because they do not consume the Pages bandwidth quota.

| Page type | Pages bytes per cold opening |
| --- | ---: |
| Home | 63.6 KiB |
| Representative note | 106.0 KiB |
| CSAPP course index | 525.0 KiB |

The representative note fetched about 1.42 MiB in total when MathJax, Mermaid, fonts, and other third-party resources were included. That affects user performance but not the GitHub Pages bandwidth calculation.

## Capacity estimate

Reserve 20% of the documented monthly bandwidth for cache misses, downloads, bots, feeds, and measurement error. The planning budget is therefore 80 GB per month.

Use:

`monthly openings = 80,000,000,000 / average Pages bytes per opening`

At the measured cold-load sizes, that budget is approximately:

| Traffic shape | Approximate monthly capacity |
| --- | ---: |
| Home-only openings | 1.23 million |
| Note-only openings | 737,000 |
| Course-index-only openings | 149,000 |
| Full course deck sessions | roughly 5,000 to 15,000 |

For planning, use 200,000 to 500,000 ordinary page openings per month when traffic is mostly notes. Course readers can consume much more bandwidth: opening a complete slide deck costs several MiB even though it records as only one or a few page views. Replace these estimates with the observed page mix after analytics has collected at least four weeks of data.

## Deployment capacity guard

`tools/check-site-budget.rb` runs in the Pages deployment workflow.

- Below 900 MiB: pass.
- 900 MiB through 929.99 MiB: pass with a warning.
- 930 MiB or above: fail the deployment before upload, leaving roughly 25 MB below the documented host limit.

Run it locally with:

```powershell
bundle exec ruby tools/check-site-budget.rb _site
```

Course assets are already the dominant size risk. Move rendered slides and large source materials to object storage or a CDN before the warning threshold is reached.

## GoatCounter operation

Hosted GoatCounter is enabled with the public site code `jingzegarden`. The dashboard is available at <https://jingzegarden.goatcounter.com/>. The `pageviews.provider` setting remains empty, so per-page visits are available in the dashboard without publishing counters in note headers.

After each analytics configuration change, build with `JEKYLL_ENV=production` and verify one request to `gc.zgo.at/count.js`, an endpoint of `https://jingzegarden.goatcounter.com/count`, and the new page in the GoatCounter dashboard. Exclude maintainer traffic using GoatCounter's documented development/visitor exclusion before evaluating trends.

The site code is a public identifier, not a secret. The dashboard remains protected by the GoatCounter account.

Automatic page tracking answers:

- visits by path, including every note;
- top entry pages and referrers;
- daily usage trends, browser/device class, and coarse geography;
- direct openings that did not originate from a tracked site click.

By default, GoatCounter de-duplicates repeated loads of the same path by the same visitor within an eight-hour session. Treat the per-note number as a visit count, not a literal reload count. This is the preferred reading metric because refreshes do not inflate it. Disable sessions in GoatCounter only if literal page-load counts are required.

## Custom events

The shared adapter sends events only when an element explicitly declares `data-analytics-event`. It does not inspect arbitrary link text, article content, form fields, or URL query parameters.

Custom events set GoatCounter's `no_session` flag, so every declared click or change is counted. Page visits remain session-de-duplicated; interaction counts do not.

| Event | Meaning | Value |
| --- | --- | --- |
| `garden_nav_click` | Primary navigation selection | stable destination slug |
| `home_featured_click` | Home recommendation opened | content UID and position |
| `search_open` | Search UI opened | fixed source |
| `search_result_click` | Search result opened | content UID and position |
| `reading_view_change` | Reading view changed | view slug |
| `reading_filter_change` | Reading filter changed | filter type and selected slug |
| `reading_sort_change` | Reading sort changed | surface and sort slug |
| `reading_note_click` | Note opened from the reading library | content UID and position |
| `post_navigation_click` | Previous/next note used | direction |
| `related_content_click` | Related note or backlink opened | relationship and content UID |
| `toc_click` | Table of contents used | heading level only |
| `focus_mode_toggle` | Focus mode changed | enabled state |

Search terms, article selections, copied text, email addresses, and other personal data must not be added to event names or values. GoatCounter receives events only after its script has loaded; analytics failures never block navigation or core features.

## Availability monitoring

The `Site Health` workflow probes the home page, reading index, and a representative course every 30 minutes. It follows redirects, bypasses caches, retries transient transport errors twice, requires a page-specific canonical URL, and fails on non-2xx responses or a 30-second timeout.

Enable GitHub Actions failure notifications for the repository. This probe runs on GitHub infrastructure, so it is not independent of a broad GitHub outage. Add an external HTTP monitor such as Better Stack or UptimeRobot for independent alerting; use a 5-minute interval and alert after two consecutive failures.

## Review cadence

Weekly:

- unique visits, note visits, top paths, entry pages, and referrers;
- search-result and reading-library click-through;
- failed health probes, HTTP 429 responses, and Pages deployment failures.

Monthly:

- estimated Pages bandwidth from actual page mix and course usage;
- generated-site size and growth by course;
- content decisions based on sustained trends, not single-day spikes.

GoatCounter is intentionally the first-stage tool. If the site later needs property-rich funnels, retention, or per-page interaction analysis, migrate the same event names to Umami rather than loading two analytics products at once.