# reporter

Issue reporter for heurema products. Claude Code plugin.

## Install

```bash
claude plugin install heurema/reporter
```

## Usage

```
/report
```

The command will:
1. Detect which heurema product you're working with
2. Ask what you want to report (bug, feature, question)
3. Collect details interactively
4. Auto-attach environment info (OS, Claude Code version, etc.)
5. Preview the issue and submit via GitHub

Requires `gh` CLI for direct submission. Falls back to clipboard + URL if unavailable.

## License

MIT
