# Tech Blog Project Overview

## Project Description
This is a personal tech blog built with Hugo, a fast and modern static site generator. The blog is hosted at [tech.yyh-gl.dev](https://tech.yyh-gl.dev/) and serves as a platform for sharing technical content and insights.

## Tech Stack
- **Hugo**: v0.146.2 (extended version) - Static Site Generator
- **Go**: v1.24.1 - Required for some tooling
- **Node.js**: Package management and dependencies
- **Docker**: Development and deployment environment
- **GitHub Pages**: Hosting platform
- **GitHub Actions**: CI/CD pipelines

## Development Setup
### Prerequisites
- Docker
- Node.js
- Go 1.24.1

### Development Environment
The project uses Docker for consistent development environment:
```dockerfile
FROM klakegg/hugo:ext
ENV TZ="Asia/Tokyo"
```

### Build & Run
The project includes several tools and dependencies:
- Hugo for site generation
- WebP for image processing
- npm packages for various functionalities
- tcardgen for generating Twitter cards

## Project Structure
```
.
├── .github/         # GitHub Actions workflows
├── archetypes/      # Template files for new content
├── assets/          # Unprocessed assets (SCSS, JS, etc.)
├── config/          # Hugo configuration files
├── content/         # Blog posts and site content
├── i18n/            # Internationalization files
├── layouts/         # Hugo templates
├── static/          # Static files
└── themes/          # Hugo themes
```

## Branch Strategy
- `main`: Primary work branch for development
- `gh-pages`: Publication branch for deployed content

## Build and Deployment
The project uses GitHub Actions for automated deployment and includes several workflows for:
- Manual deployment
- Review processes
- Deployment notifications
- Reserved deployments

## Content Management
Content is written in Markdown format and stored in the `content/` directory. The blog supports various content types including:
- Blog posts
- About page
- Static pages

## Development Guidelines
1. Always test changes locally using Docker before pushing
2. Follow the existing content structure for new blog posts
3. Ensure all images are optimized before adding to the project
4. Use the provided templates for new content creation
