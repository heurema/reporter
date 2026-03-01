# Reporter

> File bugs, request features, and ask questions for any heurema product — without leaving Claude Code.

Reporter is a Claude Code plugin with a single command that handles the full issue-filing workflow. It auto-detects which heurema product you are working with, guides you through issue details one question at a time, silently captures your environment context, lets you preview the formatted issue, and submits it via the `gh` CLI. If `gh` is unavailable, it copies the issue body to your clipboard and prints the GitHub URL so you can paste it manually.

```
$ /report bug
$ /report feature
$ /report question
```

## Quick Start

**Install via Emporium (recommended)**

<!-- INSTALL:START — auto-synced from emporium/INSTALL_REFERENCE.md -->
```bash
claude plugin marketplace add heurema/emporium
claude plugin install reporter@emporium
```
<!-- INSTALL:END -->

**First use**

Open any project that is a heurema product (or that has a heurema plugin installed) and run:

```
/report bug
```

Reporter will detect the product, ask for a title and description, attach environment info, show you a preview, and submit on confirmation.

## Key Features

- **Auto-detection** — identifies the heurema product from git remote, plugin.json, or pyproject.toml; no manual selection required.
- **Guided collection** — asks one question at a time so the experience is conversational, not form-filling.
- **Silent environment capture** — automatically appends OS, shell, and Claude Code version to every issue so maintainers have reproducibility context from the start.
- **Confirm before submit** — always previews the full issue body and waits for explicit confirmation before sending anything to GitHub.
- **Graceful fallback** — if `gh` is unavailable or unauthenticated, copies the issue body to clipboard and prints the correct GitHub URL for manual submission.

## Privacy & Data

Reporter assembles the issue body locally. No data is sent anywhere until you confirm submission. On confirmation, the issue body is posted to the detected heurema repository via `gh issue create`, which uses the GitHub API. Reporter stores no credentials — it relies entirely on your existing `gh` auth session.

## Requirements

- Claude Code with plugin support
- `gh` CLI authenticated to GitHub — optional for submission; the plugin falls back to clipboard if unavailable

## Documentation

- [How it works](docs/how-it-works.md) — flow, components, trust boundaries, limitations
- [Reference](docs/reference.md) — command usage, scenarios, output format, troubleshooting

## Links

- GitHub: https://github.com/heurema/reporter
- Marketplace: https://skill7.dev/plugins/reporter
- Changelog: CHANGELOG.md

## License

MIT
