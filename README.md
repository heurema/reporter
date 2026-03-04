# Reporter

<div align="center">

**File issues for heurema products without leaving Claude Code**

![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-5b21b6?style=flat-square)
![Version](https://img.shields.io/badge/version-0.1.0-5b21b6?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-5b21b6?style=flat-square)

```bash
claude plugin marketplace add heurema/emporium
claude plugin install reporter@emporium
```

</div>

## What it does

Filing a bug or feature request mid-session means switching to a browser, finding the right repo, and filling out a form — breaking your flow. Reporter handles the full issue-filing workflow inside Claude Code with a single command. It auto-detects which heurema product you are working with, guides you through issue details one question at a time, and submits via the `gh` CLI. If `gh` is unavailable, it copies the issue body to your clipboard and prints the GitHub URL so you can paste it manually.

## Install

<!-- INSTALL:START — auto-synced from emporium/INSTALL_REFERENCE.md -->
```bash
claude plugin marketplace add heurema/emporium
claude plugin install reporter@emporium
```
<!-- INSTALL:END -->

<details>
<summary>Manual install from source</summary>

```bash
git clone https://github.com/heurema/reporter
cd reporter
claude plugin install .
```

</details>

## Quick start

Open any project that uses a heurema product and run:

```
/report bug
```

Reporter detects the product, asks for a title and description, attaches environment info, shows a preview, and submits on confirmation.

## Commands

| Command | Description |
|---|---|
| `/report bug` | File a bug report for the detected heurema product |
| `/report feature` | Request a new feature |
| `/report question` | Ask a question via a GitHub issue |

## Features

- **Auto-detection** — identifies the heurema product from git remote, plugin.json, or pyproject.toml; no manual selection required
- **Guided collection** — asks one question at a time so the experience is conversational, not form-filling
- **Silent environment capture** — automatically appends OS, shell, and Claude Code version to every issue so maintainers have reproducibility context from the start
- **Confirm before submit** — always previews the full issue body and waits for explicit confirmation before sending anything to GitHub
- **Graceful fallback** — if `gh` is unavailable or unauthenticated, copies the issue body to clipboard and prints the correct GitHub URL for manual submission

## Requirements

- Claude Code with plugin support
- `gh` CLI authenticated to GitHub — optional for submission; the plugin falls back to clipboard if unavailable

## Privacy

Reporter assembles the issue body locally. No data is sent anywhere until you confirm submission. On confirmation, the issue body is posted to the detected heurema repository via `gh issue create`, which uses the GitHub API. Reporter stores no credentials — it relies entirely on your existing `gh` auth session.

## See also

- [skill7.dev](https://skill7.dev) — plugin marketplace and documentation hub
- [Emporium](https://github.com/heurema/emporium) — heurema plugin registry
- [Reporter on skill7.dev](https://skill7.dev/plugins/reporter) — plugin page, changelog, and release notes
- [How it works](docs/how-it-works.md) — flow, components, trust boundaries, limitations
- [Reference](docs/reference.md) — command usage, scenarios, output format, troubleshooting

## License

[MIT](LICENSE)
