# gaurig.com

Source repository for [gaurig.com](https://gaurig.com/), a personal blog built with [Hugo](https://gohugo.io/) and the [Stack](https://github.com/CaiJimmy/hugo-theme-stack) theme. Content is written in Markdown, built into a static site, and deployed to GitHub Pages by GitHub Actions on every push to `main`.

## Tech stack

| Component | Details |
|---|---|
| Static site generator | Hugo Extended `0.166.0` (pinned) |
| Theme | Stack `v4.0.3`, included as a Git submodule |
| CI/CD | GitHub Actions |
| Hosting | GitHub Pages |
| Domain | `gaurig.com` |

## Getting started

### Prerequisites

- [Git](https://git-scm.com/)
- [Hugo **Extended**](https://github.com/gohugoio/hugo/releases) `0.166.0`. The Extended edition is required because Stack compiles SCSS. Stack itself requires Hugo `0.157.0` or newer.

### Clone

The theme is a Git submodule, so clone with submodules:

```bash
git clone --recurse-submodules https://github.com/guptg/guptg.github.io.git
cd guptg.github.io
```

If you already cloned without them, fetch the theme with:

```bash
git submodule update --init --recursive
```

### Run locally

```bash
hugo server
```

This serves the site locally, builds it in memory, and rebuilds as files change. Add `-D` to include posts marked as drafts.

### Production build

```bash
hugo --gc --minify
```

The built site is written to `public/`, which is generated output and is not committed.

### Setting up a new WSL machine

Ubuntu's package repositories often carry an older Hugo than this project needs. `setup-wsl.sh` installs the pinned Hugo Extended release and verifies that the Stack submodule is on the expected version and commit. It contains hard-coded paths, so read the comments at the top of the script before running it with `bash setup-wsl.sh`.

## Project structure

```
.
├── .github/
│   ├── workflows/hugo.yaml        # Build and deploy workflow
│   └── copilot-instructions.md    # Guidance for AI coding assistants
├── archetypes/                    # Templates for new content
├── assets/                        # Project-level asset overrides
├── content/                       # Site content in Markdown
│   └── post/                      # Blog posts
├── data/                          # Data files available to templates
├── i18n/                          # Translation string overrides
├── layouts/                       # Project-level template overrides
├── static/                        # Files copied to the site as-is
├── themes/
│   └── hugo-theme-stack/          # Stack theme (Git submodule)
├── .gitignore
├── .gitmodules
├── hugo.toml                      # Site configuration
├── setup-wsl.sh                   # One-time WSL environment setup
└── README.md
```

Hugo also creates `public/` (the built site) and `resources/_gen/` (a cache of processed assets) while building. Both are listed in `.gitignore`.

## Writing content

Posts live in `content/post/` as Markdown files with TOML front matter. Create a new one with:

```bash
hugo new content post/my-new-post.md
```

A post is published only when `draft = false` in its front matter. The `content/` folder is also used as an Obsidian vault, so stick to standard Hugo-compatible Markdown.

## Deployment

Pushing to `main` runs `.github/workflows/hugo.yaml`, which:

1. Checks out the repository, including the theme submodule.
2. Installs the pinned Hugo Extended version.
3. Builds the site with `hugo --gc --minify`.
4. Uploads the `public/` folder as an artifact.
5. Deploys that artifact to GitHub Pages in a separate job.

The workflow can also be started manually from the repository's Actions tab. For deployment to work, the repository's Pages source must be set to **GitHub Actions** (Settings, then Pages).

## Theme

Stack is included as a Git submodule and is treated as read-only. To customize the site, add files at the same path in the project-level `layouts/`, `assets/` or `static/` folders, which take precedence over the theme's files.

To update Stack, check its minimum Hugo version in `themes/hugo-theme-stack/theme.toml` first, then update the pinned theme version in `setup-wsl.sh` and the pinned Hugo version in both `setup-wsl.sh` and `.github/workflows/hugo.yaml` if needed.

## Credits

Built with [Hugo](https://gohugo.io/) and the [Stack](https://github.com/CaiJimmy/hugo-theme-stack) theme by Jimmy Cai.
