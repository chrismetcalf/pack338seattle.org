# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A two-page Jekyll 4.3 marketing site for Cub Scout Pack 338 (Seattle), deployed to GitHub Pages at the apex domain `pack338seattle.org` (see `CNAME`). There is no test suite, no linter, and no JS/CSS build step — Bootstrap 5 and Font Awesome load from CDNs in the layout, and `assets/css/style.css` + `assets/js/main.js` are served as-authored.

## Commands

```bash
./setup-ruby.sh                     # one-time: rbenv + Ruby 3.2 + bundle install
./serve.sh                          # dev server on http://localhost:4000, livereload on
./serve.sh --tailscale              # also bind the tailnet address (prints MagicDNS URL)
./serve.sh --lan                    # bind 0.0.0.0 for local-network access
PORT=4001 ./serve.sh                # any port
bundle exec jekyll build            # output to _site/ (gitignored)
bundle exec jekyll clean            # clear _site/ and .jekyll-cache/
JEKYLL_ENV=production bundle exec jekyll build

TZ=America/Los_Angeles ruby script/fetch-events.rb              # refresh _data/events.yml
TZ=America/Los_Angeles ruby script/fetch-events.rb --file x.ics # parse a local feed instead
```

Linux-first (macOS works; `setup-ruby.sh` handles apt/dnf/pacman/zypper/brew). `serve.sh` passes unrecognized arguments through to `jekyll serve`.

`Gemfile.lock` covers both `x86_64-linux` (glibc — what CI and most distros use) and `x86_64-linux-musl` (Alpine/containers). If you add a platform, run `bundle lock --add-platform <platform>` and commit the lock rather than letting each machine re-resolve.

`_config.yml` excludes `*.sh`, `README.md`, `CLAUDE.md`, and `assets/images/README.md` — without those entries Jekyll copies the dev scripts and docs straight into `_site/` and publishes them.

Deployment is automatic: pushing to `main` triggers `.github/workflows/jekyll.yml`, which builds with Ruby 3.2 and publishes `_site/` to GitHub Pages. Note the workflow's build step reads `steps.page-setup.outputs.base_path` from a `Setup Pages` step declared *after* it, so `--baseurl` resolves to empty — harmless for an apex-domain deploy, but don't rely on that variable if you touch the workflow.

## Structure and gotchas

**Every page must declare `layout: default` in its front matter.** `_layouts/default.html` is the only layout that exists. `_config.yml` sets defaults of `layout: page` for pages and `layout: post` for posts — neither layout file exists, so any new page that omits an explicit layout will fail to build. There are no posts despite the `posts` collection config.

**Content pages:** `index.html` (single-page site: hero, about, what-we-do, the year, how-to-join, signup, contact), `signup.html` (standalone mobile-bookmarkable signup), and `404.html`. Nav links live in `_layouts/default.html`, not in the pages.

**Copy follows the branding guidelines**, kept in the vault at `01 - Personal/01.10 - Projects/01.10.20 - Pack 338/Pack 338 Branding Guidelines.md`. Read it before rewording anything outward-facing. The rules that get broken most: **"kids of all genders"** (never "any gender", "both genders", or "boys and girls"), **"grades K–5"** with an en dash, and the Oxford comma in every list of three or more. Openness gets stated on all three dimensions — gender, school, and creed — never left to inference, because the pack meets at a parish school and silence makes families screen themselves out.

**Never publish a proposed date.** `_data/year.yml` carries months and themes only, no dates, because the 2026–27 calendar is still proposed. Dates reach the site solely through `_data/events.yml`, which is generated from the Groups.io calendar — i.e. from dates already locked. Keep it that way: a date published here cannot be retracted.

**The meeting address is the school, `3520 NE 89th St` (Wedgwood)** — never the parish address `8900 35th Ave NE`, which sends families to the church instead of the school MPR. Both appear in older pack documents.

**Pack facts live in `_data/pack.yml`** — address, email, meeting pattern, Groups.io URLs, honeypot field name. Templates read `site.data.pack.*`; don't hardcode the address or email in markup again. This exists so a non-developer can change the meeting time without touching HTML.

**The Groups.io signup form is `_includes/signup-form.html`**, used by both pages (`{% include signup-form.html shadow=true %}` on the signup page). Its CSS moved into `style.css`; the signup page's overrides are scoped under `.signup-page` so the homepage form keeps its own layout. The hidden honeypot input is anti-bot — do not remove it.

**Upcoming events are fetched at build time, not in the browser.** `script/fetch-events.rb` pulls the Groups.io `.ics`, parses it (RFC 5545 unfolding, `DTSTART;TZID=...` parameters, text escapes, http(s)-only URLs), and writes upcoming events to `_data/events.yml`. `.github/workflows/update-events.yml` runs it daily at 13:00 UTC and commits changes, which triggers a deploy. `_includes/upcoming-events.html` renders from that data and filters by `site.time`, so no JavaScript is involved.

Run the script with `TZ=America/Los_Angeles` — floating and TZID-qualified times are interpreted in the process timezone, and `_config.yml` sets the same zone so Liquid's date filters format them consistently. Groups.io returns **403 to the default Ruby user agent**, so the script sends a browser-like one; if the feed suddenly 403s in CI, check that first.

This replaced a browser-side fetch through public CORS proxies (`api.allorigins.win` and two others). All three proxies are now dead, which is what took the events widget down. Don't reintroduce that pattern.

**The empty state is a real state, not an error.** Between scouting years the feed legitimately has no future events, so `_includes/upcoming-events.html` falls back to the meeting pattern from `_data/pack.yml` plus a mailing-list nudge. Keep that path useful — for much of the summer it *is* the page.

**Anchor links must survive being clicked from a page that lacks the target.** The nav lives in the layout and is shared by both pages, so its links are absolute (`{{ '/' | relative_url }}#about`). The smooth-scroll handler in `main.js` only calls `preventDefault()` once it has confirmed the target exists on the current page; anything else falls through to normal browser navigation. Don't "simplify" that back to an unconditional `preventDefault()` — that silently kills the nav on `/signup/`.

**Theme colors** are CSS custom properties in the `:root` block of `assets/css/style.css`.

**Images.** The hero is referenced only from CSS: `fire_pit.jpg` (1400px) with a WebP alternative via `image-set()`, swapped for the `-800` variants under 768px. `og-image.jpg` is a 1200×630 crop used by the Open Graph tags in the layout — keep those dimensions, they're declared in the markup. `apple-touch-icon.png` is 180×180 for iOS home-screen bookmarks. All are generated from the same source photo with ImageMagick.

**Social meta is hand-rolled** in `_layouts/default.html` (Open Graph + Twitter card, absolute URLs via `absolute_url`). `jekyll-seo-tag` is deliberately not installed — it would duplicate these tags. `jekyll-sitemap` is installed and `robots.txt` points at the generated sitemap.

**Adding a site-wide announcement bar:** markup goes in `_layouts/default.html` under the fixed navbar, and `.hero-section` padding must be increased to compensate (it was `140px` desktop / `120px` mobile with a bar, and is `80px` desktop / `80px 0 60px` mobile without). The `.announcement-bar` CSS is still present in `style.css` even though no page currently uses it. Commit `cce343b` shows the add, `b8cd46d` the removal.
