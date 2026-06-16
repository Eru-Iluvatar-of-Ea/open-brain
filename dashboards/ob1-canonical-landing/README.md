# Open Brain Landing Page (adapted)

A cite-able single-page landing for Open Brain — full SEO meta, JSON-LD structured data
(`TechArticle` + `DefinedTerm`), bundled OB1 brand assets, WCAG 2.1 AA accessibility, and
all crawler companion files (`sitemap.xml`, `robots.txt`, `llms.txt`, `site.webmanifest`,
`404.html`). Static HTML — no build step, no dependencies, no framework.

> **Adapted copy.** This is the upstream OB1 contribution
> [`dashboards/ob1-canonical-landing`](https://github.com/NateBJones-Projects/OB1/tree/main/dashboards/ob1-canonical-landing)
> by Sam Rogers (`snapsynapse`), re-homed for this repository. The original is built for
> `openbrain.fyi`; this copy is configured to serve from **GitHub Pages at
> `https://eru-iluvatar-of-ea.github.io/open-brain/`** (project subpath, no custom domain).
> Original license: **FSL-1.1-MIT** (see the OB1 repo's `LICENSE.md`).

## What was changed from upstream

- **`CNAME` deleted** — we don't own `openbrain.fyi`. A project Pages site needs no CNAME.
- **Absolute host URLs re-homed** to `https://eru-iluvatar-of-ea.github.io/open-brain/`:
  `<link rel="canonical">`, `og:url`/`og:image`, `twitter:image`, both JSON-LD blocks,
  `sitemap.xml` `<loc>`, `robots.txt` `Sitemap:`, and the `llms.txt` homepage links.
- **In-page asset paths made relative** in `index.html` (`imgs/…`, `site.webmanifest`,
  `sitemap.xml`) so they resolve correctly under the `/open-brain/` subpath.
- **`404.html` and `site.webmanifest`** use root-absolute `/open-brain/…` paths (GitHub
  Pages serves `404.html` for unknown paths at any depth, so relative paths there would break).
- Page copy, branding, and upstream links (GitHub, Discord, Substack, byline) are **unchanged**.

## Prerequisites

- This repo is public, so GitHub Pages is available on the free plan.
- No Open Brain backend setup is required to deploy this page.

## Setup

### Step 1 — Confirm the deploy workflow

`.github/workflows/deploy-pages.yml` (added at the repo root) deploys this folder to Pages
on any push to `main` that touches `dashboards/ob1-canonical-landing/**`, or on manual
dispatch. It uploads `dashboards/ob1-canonical-landing/` as the site root.

### Step 2 — Enable GitHub Pages

This is a one-time setting you do in the GitHub web UI (it can't be set from the CLI):

1. Repo **Settings → Pages**
2. Under **Build and deployment → Source**, select **GitHub Actions**

No custom domain field — the site serves at `https://eru-iluvatar-of-ea.github.io/open-brain/`.

### Step 3 — Trigger the deploy

Push any change under `dashboards/ob1-canonical-landing/`, or run it manually via
**Actions → Deploy landing page → Run workflow**. The site is live once the `deploy` job
succeeds. (HTTPS is automatic on `*.github.io` — no certificate step.)

## Expected outcome

- `https://eru-iluvatar-of-ea.github.io/open-brain/` serves the landing page over HTTPS
- `/open-brain/sitemap.xml`, `/open-brain/robots.txt`, and `/open-brain/llms.txt` return `200`
- An unknown path under `/open-brain/` returns the branded 404 page

Verify:

```bash
base="https://eru-iluvatar-of-ea.github.io/open-brain"
curl -sI "$base/" | grep -iE "^(HTTP|server|content-type)"
for p in / /sitemap.xml /robots.txt /llms.txt /site.webmanifest; do
  printf "%-18s %s\n" "$p" "$(curl -s -o /dev/null -w "%{http_code}" "$base$p")"
done
```

Expect `HTTP/2 200`, `server: GitHub.com`, and `200` for every path.

## Files

| File | Purpose |
|------|---------|
| `index.html` | Landing page |
| `MAINTENANCE.md` | Post-deploy guide for editing copy, swapping assets, validating, verifying |
| `404.html` | Branded 404 with `noindex` and return-home link |
| `sitemap.xml` | Single-URL sitemap for crawler discoverability |
| `robots.txt` | Allow all crawlers, point to sitemap |
| `llms.txt` | LLM-readable project summary following the llms.txt convention |
| `site.webmanifest` | Web app manifest for Android home-screen affordance |
| `metadata.json` | Contribution metadata (original author attribution) |
| `imgs/ob1-logo.png` | Square OB1 brand logo (512×512), nav + manifest icon |
| `imgs/ob1-logo-wide.png` | Wide OB1 banner (1200×360), hero image |
| `imgs/og.png` | Social share image (1200×630) |
| `imgs/favicon-32.png` | 32×32 favicon |
| `imgs/apple-touch-icon.png` | 180×180 iOS home-screen icon |

> **Note:** there is intentionally **no `CNAME`** file. Do not add one unless you point a
> custom domain you own at this repo's Pages — and if you do, re-home the absolute URLs in
> `index.html`, `sitemap.xml`, `robots.txt`, `llms.txt`, `site.webmanifest`, and `404.html`
> to that domain (and drop the `/open-brain/` subpath, since a custom apex domain serves at root).

## Troubleshooting

**Workflow fails with a permissions error.** Settings → Actions → General → Workflow
permissions → "Read and write permissions". The workflow also declares `pages: write` and
`id-token: write`, which the **GitHub Actions** Pages source grants.

**Site 404s after the workflow succeeds.** Confirm Settings → Pages → Source is
**GitHub Actions** (not "Deploy from a branch"). Give it a minute for first publish.

**Assets 404 but the page loads.** A path got left as root-absolute (`/imgs/…`) instead of
relative or `/open-brain/…`. Re-check against "What was changed from upstream" above.
