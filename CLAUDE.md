# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Hugo static site blog running in Docker. Hugo v0.146.2 (extended), theme: hugo-future-imperfect-slim.

- `main` branch: work branch
- `gh-pages` branch: publication branch

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

textlint with `textlint-rule-preset-ja-technical-writing` enforces Japanese writing quality. Lint runs against files changed since the previous commit (`git diff --name-only HEAD~`).

### OGP Image Generation

Uses `tcardgen` tool inside the Docker container, configured by `template.yaml`. Outputs WebP to `static/img/YYYY/MM/<slug>/featured.webp`.

### Config

Hugo config is in `config/_default/config.toml`. Environment-specific overrides in `config/production/`.
