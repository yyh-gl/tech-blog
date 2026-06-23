# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Hugo static site blog running in Docker. Hugo v0.146.2 (extended), theme: hugo-future-imperfect-slim (managed via Hugo Modules, not a git submodule).

- `main` branch: work branch
- `gh-pages` branch: publication branch
- Live URL: https://tech.yyh-gl.dev/

## Directory Structure

```
.
├── archetypes/          # Hugo article templates
├── assets/              # SCSS and JavaScript sources (compiled by Hugo)
│   ├── js/
│   └── scss/
├── config/
│   ├── _default/        # config.toml (base config)
│   └── production/      # config.toml (Google Analytics ID only)
├── content/
│   ├── about/
│   ├── blog/            # Blog articles (~60 posts)
│   ├── business/
│   ├── contact/
│   └── stats/
├── docs/
├── i18n/                # ja.toml (Japanese UI strings)
├── layouts/             # Custom template overrides (edit here, never in themes/)
├── static/
│   ├── css/             # style.css, prism.css, add-on.css
│   ├── favicon/
│   ├── font/            # Kinto Sans font (used for OGP image generation)
│   ├── img/             # Images organized by year/month/slug
│   └── js/              # vue.min.js, prism.js, good-counter.js, add-on.js
├── Dockerfile
├── Makefile
├── package.json         # pnpm project (textlint, postcss, etc.)
├── pnpm-workspace.yaml
├── postcss.config.js    # PurgeCSS config
├── staticman.yml        # Comment system config
└── template.yaml        # OGP image generation config (tcardgen)
```

## Commands

All development is done inside Docker. Start the container first, then run commands against it.

```bash
# Initial setup (build Docker image)
make setup

# Start Hugo dev server (http://<local-ip>:1313)
make server

# Login to the running container
make login

# Lint changed files (textlint, run while server is running)
make lint

# Create a new article (creates branch, generates template, opens browser)
make new title=<article-slug>

# Generate OGP image for an article
make create-ogp title=<article-slug>

# Convert PNG/JPG images to WebP
make convert-to-webp title=<article-slug>

# Register article for like-count tracking
make init-blog-like-count title=<article-slug>
```

Package manager: **pnpm** (not npm).

## Architecture

### Content

Articles are in `content/blog/<slug>.md` with TOML frontmatter:

```toml
+++
title = ""
author = "yyh-gl"
categories = [""]
tags = ["Tech"]
date = 2025-01-10T19:34:56+09:00
description = ""
type = "post"
draft = false
[[images]]
  src = "img/YYYY/MM/<slug>/featured.webp"
  alt = "featured"
  stretch = "stretchH"
+++
```

Images go in `static/img/YYYY/MM/<slug>/`. The featured image must be WebP format named `featured.webp`.

### Linting

textlint with `textlint-rule-preset-ja-technical-writing` enforces Japanese writing quality. Lint runs against files changed since the previous commit (`git diff --name-only HEAD~`). The `.textlintrc` excludes TOML frontmatter blocks (`+++...+++`). GitHub Actions also runs textlint on PRs (`review.yml`).

### OGP Image Generation

Uses `tcardgen` tool inside the Docker container, configured by `template.yaml`. Background image: `static/img/main/ogp_image_large.png`. Font: Kinto Sans (`static/font/kinto-master/`). Outputs WebP to `static/img/YYYY/MM/<slug>/featured.webp`.

### Theme

**NEVER modify files under `themes/hugo-future-imperfect-slim/`.** This directory is a third-party theme and must not be changed.

All UI customizations must be done in `layouts/` (Hugo's template override mechanism).

Key layout files:
- `layouts/_default/baseof.html` — base HTML structure
- `layouts/_default/single.html` — article detail page
- `layouts/_default/list.html` — article list page
- `layouts/_default/header.html` — site header
- `layouts/_default/_markup/render-link.html` — external links open in new tab
- `layouts/index.html` — home page (terminal-style UI with `$` prompt)

### Config

Hugo config is in `config/_default/config.toml`. Environment-specific overrides in `config/production/` (only sets Google Analytics ID `G-Q3B9GBPE91`).

Key config values:
- `baseurl`: `https://tech.yyh-gl.dev/`
- `DefaultContentLanguage`: `ja`
- `pagerSize`: 5

### Features

- **Like counter**: Vue.js + `good-counter.js` calls external API at `https://hobigon.yyh-gl.dev/api/v1/blogs/`. State stored in `localStorage`.
- **Syntax highlighting**: Prism.js (`static/js/prism.js`, `static/css/prism.css`).
- **Comment system**: Staticman (`staticman.yml`), stores comments as JSON in `data/comments/`.
- **CSS optimization**: PostCSS + PurgeCSS (`postcss.config.js`) scans `layouts/` and `content/`.

### CI/CD (GitHub Actions)

- `review.yml` — textlint on PR diffs
- `manual-deployment.yml` — manual trigger: Hugo build → push to `gh-pages`
- `deploy-notification.yml` — deployment notifications
- `reserved-deployment.yml` — scheduled deployments
