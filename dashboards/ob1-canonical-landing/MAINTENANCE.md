# Maintaining the Open Brain landing page

This guide covers updating the landing page after it goes live. The page is a single static
`index.html` with no build step — every change is a normal git edit, and every deploy is a
single push.

> This is an adapted copy of the upstream OB1 contribution, re-homed to serve from
> **GitHub Pages at `https://eru-iluvatar-of-ea.github.io/open-brain/`** (project subpath,
> no custom domain). See `README.md` for what was changed from upstream.

## Edit-and-deploy loop

1. Edit any file under `dashboards/ob1-canonical-landing/`
2. Push to `main` (or open a PR and merge)
3. The `Deploy landing page` workflow fires on the path filter and pushes the artifact to Pages
4. `https://eru-iluvatar-of-ea.github.io/open-brain/` refreshes within 1–2 minutes of the deploy job finishing

Watch progress at **Actions → Deploy landing page**. The job's environment URL links to the live site once it's published.

## Common edits

### Update copy, headlines, or links

All visible text lives directly in `index.html`. The major sections are marked with HTML `id`s for navigation:

| `id` | Section |
|------|---------|
| `main-content` | Skip-link target, wraps everything below the nav |
| (hero, no id) | The first `<section class="hero">` — h1, byline, CTA buttons, demo video |
| `how-it-works` | Three-pillar overview |
| `get-started` | Numbered steps + AI-assistant cards + companion prompts |
| `extensions` | Extensions table |
| `community` | Recipes + tools + skills tables, dashboards/integrations pillars |

After any copy change, update the modified date in all of these so search engines and citations stay in sync:

| File | Field |
|------|-------|
| `index.html` | `<meta property="article:modified_time" content="...">` |
| `index.html` | JSON-LD `TechArticle` → `"dateModified"` |
| `index.html` | Byline `<time datetime="...">Updated ...</time>` |
| `sitemap.xml` | `<lastmod>` |
| `metadata.json` | `"updated"` |

All should be the same ISO date (`YYYY-MM-DD`).

### Add or swap a video

Videos use GitHub user-attachment URLs (the same URLs that render in a project README). To add a new video:

1. Drag the `.mp4` into a GitHub issue or PR comment to upload it; copy the `https://github.com/user-attachments/assets/...` URL
2. Embed using the existing pattern:

```html
<video class="inline-video" controls preload="none" playsinline aria-label="Brief description">
  <source src="https://github.com/user-attachments/assets/UUID" type="video/mp4">
  <a href="https://github.com/NateBJones-Projects/OB1" target="_blank" rel="noopener">Watch on GitHub</a>
</video>
```

Always set a meaningful `aria-label` — screen readers announce it. Use `preload="metadata"` only for the hero video; keep all below-fold videos at `preload="none"` to protect first-paint performance.

If a GitHub user-attachment URL ever goes 404, replace with a re-uploaded asset; do not host video binaries in the repo.

### Replace or update the logo

The page ships three brand-image variants generated from a single source:

| File | Use | Source |
|------|-----|--------|
| `imgs/ob1-logo.png` (512×512) | Nav + manifest icon | Square master |
| `imgs/ob1-logo-wide.png` (1200×360) | Hero banner | Wide master |
| `imgs/og.png` (1200×630) | Social share | Wide on `#0f1b33` background |
| `imgs/apple-touch-icon.png` (180×180) | iOS home screen | Square master |
| `imgs/favicon-32.png` (32×32) | Browser tab | Square master |

To regenerate from new master images, drop the new sources at `imgs/_master-square.png` and `imgs/_master-wide.png`, then run:

```bash
cd dashboards/ob1-canonical-landing/imgs
magick _master-square.png -resize 512x512 -strip ob1-logo.png
magick _master-square.png -resize 180x180 -strip apple-touch-icon.png
magick _master-square.png -resize 32x32  -strip favicon-32.png
magick _master-wide.png   -resize 1200x  -strip ob1-logo-wide.png
magick _master-wide.png   -resize 1000x -background "#0f1b33" -gravity center -extent 1200x630 og.png
rm _master-square.png _master-wide.png
```

Requires ImageMagick 7+ (`brew install imagemagick`). The `-strip` flag removes EXIF/color-profile metadata that bloats files and leaks build-environment info.

If the logo's color palette changes, update the CSS custom properties in the `:root` block of `index.html`:

```css
--accent: #e05a20;          /* primary accent (OB1 orange) */
--brand-blue-deep: #0f1b33; /* used in hero gradient + OG bg */
--brand-blue-mid: #1a3a6e;
--brand-blue-bright: #2563b8;
```

### Add a new content section

Use the existing pattern so styling, spacing, and a11y stay consistent:

```html
<section id="kebab-case-id">
  <div class="container">
    <h2>Section title</h2>
    <p>Lead paragraph.</p>
    <!-- content -->
  </div>
</section>
```

Alternate `<section>` and `<section class="alt">` for visual rhythm. Add a nav link in the sticky `<nav>` block if the section is top-level.

Heading hierarchy must stay clean: one `<h1>` (in the hero), `<h2>` per section, `<h3>` for sub-blocks. Skipping levels breaks screen-reader navigation.

### Update the byline

The page is currently bylined to Nate B. Jones (upstream author). If you change authorship, update **all** of these in lockstep:

- `<meta name="author">`
- `<meta property="article:author">`
- `<meta name="twitter:creator">`
- JSON-LD `TechArticle` → `author`
- The visible `.byline` block in the hero

## Pre-deploy validation

Run these locally before pushing significant changes. None are part of the deploy workflow — they're discretionary checks that catch most regressions.

### Structured data

```bash
# Extract JSON-LD blocks and parse them
python3 -c "
import re, json
html = open('dashboards/ob1-canonical-landing/index.html').read()
for i, m in enumerate(re.finditer(r'<script type=\"application/ld\\+json\">(.+?)</script>', html, re.DOTALL)):
    try:
        json.loads(m.group(1)); print(f'block {i+1}: ok')
    except Exception as e:
        print(f'block {i+1}: FAIL — {e}')
"
```

After deploy, paste the live URL into [Google's Rich Results Test](https://search.google.com/test/rich-results) and the [Schema.org Validator](https://validator.schema.org/) after any JSON-LD edit.

### Accessibility

The page targets WCAG 2.1 AA. Run [axe DevTools](https://www.deque.com/axe/devtools/) in Chrome or [Pa11y](https://pa11y.org/) against the live URL:

```bash
npx pa11y --standard WCAG2AA https://eru-iluvatar-of-ea.github.io/open-brain/
```

Common things that break it: text on the orange accent (use `var(--bg)` not `var(--text)` for contrast); missing `alt` on new images; nested interactive elements (a button inside an anchor, or vice versa).

### Link health

```bash
# Quick check — should return zero broken external links
grep -oE 'href="https?://[^"]+"' dashboards/ob1-canonical-landing/index.html \
  | sort -u \
  | sed 's/href="//;s/"$//' \
  | xargs -P 8 -I{} curl -sLo /dev/null -w "%{http_code} {}\n" {} \
  | grep -v "^200"
```

### Size budget

The page should stay under 60KB HTML and 200KB total assets. Check:

```bash
du -sh dashboards/ob1-canonical-landing/index.html dashboards/ob1-canonical-landing/imgs/
```

If either grows substantially, audit before merging. Optimize new images with `magick INPUT -strip -quality 85 OUTPUT` before committing.

## Post-deploy verification

After every meaningful edit, spot-check production:

```bash
base="https://eru-iluvatar-of-ea.github.io/open-brain"

# Page resolves with HTTPS, served by GitHub
curl -sI "$base/" | grep -iE "^(HTTP|server|content-type|x-github)"

# Crawler files all return 200
for p in / /sitemap.xml /robots.txt /llms.txt /site.webmanifest; do
  printf "%-18s %s\n" "$p" "$(curl -s -o /dev/null -w "%{http_code}" "$base$p")"
done

# 404 page works (GitHub Pages serves the project 404 for any unknown path under /open-brain/)
curl -s -o /dev/null -w "%{http_code}\n" "$base/this-does-not-exist"
# Expected: 404
```

If anything looks off, check **Actions → Deploy landing page** for the most recent run's logs and the deploy environment URL.

## HTTPS

Certificates on `*.github.io` are managed by GitHub automatically — no action needed. There is no custom domain and no DNS to maintain. (If you later attach a custom domain you own, see the note at the end of `README.md` and GitHub's custom-domain docs.)

## Decommissioning

To stop serving the page:

1. **Settings → Pages → Source**: set back to "Deploy from a branch" / None, or
2. Disable the workflow (rename `.github/workflows/deploy-pages.yml` to `*.disabled`, or delete it)

The page can stay in the repo as a reference template even when not served live.

## Files at a glance

See the **Files** table in `README.md`. Every file in this folder is purposeful.

## Original template

This page is adapted from the upstream contribution at
[`NateBJones-Projects/OB1`](https://github.com/NateBJones-Projects/OB1/tree/main/dashboards/ob1-canonical-landing).
Improvements to the template itself are best contributed upstream there.
