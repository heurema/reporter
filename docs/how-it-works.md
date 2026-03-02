# How Reporter Works

Reporter is a single-command Claude Code plugin. It has no agents, no skills, no hook scripts, and no background processes. The entire workflow — product detection, interactive collection, environment capture, preview, and submission — is orchestrated by the LLM driving the `/report` command, using `Bash` and `Read` tool calls as needed.

## Architecture

```
┌──────────────┐   ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
│   Detect     │──>│   Collect    │──>│   Preview    │──>│   Submit     │
│ (Bash probes)│   │ (LLM dialog) │   │ (LLM render) │   │  (Bash: gh)  │
└──────────────┘   └──────────────┘   └──────────────┘   └──────────────┘
       │                  │                  │                   │
       ▼                  ▼                  ▼                   ▼
  REPO_NAME          answers             formatted           GitHub URL
                   (title, desc,        issue body          or clipboard
                    repro, etc.)        + env section         fallback
```

All state is in-memory for the duration of the session. The only file written to disk is a temp file used to pass the issue body to `gh issue create`, which is deleted immediately after.

## Components

| Component | File | Purpose |
|-----------|------|---------|
| Command definition | `commands/report.md` | Full workflow: detection, collection, formatting, submission |

Reporter has a single component. There are no separate agent files, skill files, or hook files.

The command is triggered by the slash command `/report` and also by natural-language phrases: "report a bug", "file an issue", "report issue". It accepts an optional argument (`bug`, `feature`, `question`) that sets the issue type without prompting.

Allowed tools: `Bash`, `Read`.

## Step-by-Step Flow

### Step 1: Product detection

Reporter runs three bash probes in order and stops at the first hit:

1. **Git remote:**
   ```bash
   git remote get-url origin 2>/dev/null | sed 's|.*heurema/||; s|\.git$||'
   ```
2. **plugin.json** — searches up to 3 directory levels deep for `plugin.json` inside a `.claude-plugin/` directory and reads the `name` field via `python3 -c "import sys,json; ..."`.
3. **pyproject.toml** — reads `project.name` via `python3 -c "import tomllib, pathlib; ..."`.

If all three fail, Reporter prompts: "Which heurema product is this about?" and offers choices: proofpack, signum, anvil, herald, skill7.dev, teams-field-guide, or Other.

### Step 2: Check `gh` availability

```bash
command -v gh >/dev/null 2>&1 && gh auth status 2>&1 | head -3 || echo "GH_UNAVAILABLE"
```

If the output contains "GH_UNAVAILABLE" or "not logged in", the fallback path is used at submission time. Collection continues regardless.

### Step 3: Issue type

If the user passed an argument (`/report bug`, `/report feature`, `/report question`), this step is skipped. Otherwise Reporter asks the user to choose from Bug Report, Feature Request, or Question.

### Step 4: Guided detail collection

Questions are asked one at a time. Required fields are enforced; optional fields can be skipped.

**Bug Report:**
1. Short title (required)
2. What happened (required)
3. What did you expect to happen (optional)
4. Steps to reproduce (optional)
5. How often: always, sometimes, or one-off (optional)

**Feature Request:**
1. Short title (required)
2. What feature (required)
3. Why is it useful / what problem does it solve (optional)

**Question:**
1. Short title (required)
2. The question (required)
3. Context / what are you trying to do (optional)

### Step 5: Silent environment capture

Reporter runs the following without prompting the user:

```bash
echo "OS: $(uname -s) $(uname -r)"
echo "Shell: $SHELL"
echo "Claude Code: $(claude --version 2>/dev/null || echo 'unknown')"
```

The output is appended as an `## Environment` section in the issue body.

### Step 6: Preview and confirmation

The full issue title and body are displayed. The user chooses Submit, Edit, or Cancel. Edit loops back to collection. Cancel stops with no side effects. Nothing is sent anywhere until Submit is confirmed.

### Step 7: Submission

**With `gh` available:** The body is written to a temp file (to avoid shell quoting issues) and submitted:

```bash
TMPFILE=$(mktemp)
cat > "$TMPFILE" <<'ISSUE_BODY'
<formatted body>
ISSUE_BODY
gh issue create -R "heurema/REPO_NAME" \
  --title "TITLE_HERE" \
  --body-file "$TMPFILE" \
  --label "LABEL"
rm -f "$TMPFILE"
```

Labels: `bug`, `enhancement`, or `question`. If the label does not exist in the target repo, Reporter retries without `--label`. Reporter prints the returned issue URL.

**Without `gh`:** The body is copied to clipboard (`pbcopy` on macOS, `xclip` or `xsel` on Linux, falling back to printing if none work). Reporter prints the correct GitHub new-issue URL:
- Bug: `https://github.com/heurema/REPO_NAME/issues/new?template=bug_report.md`
- Feature: `https://github.com/heurema/REPO_NAME/issues/new?template=feature_request.md`
- Question: `https://github.com/heurema/REPO_NAME/issues/new?template=question.md`

## Trust Boundaries

**Stays entirely local:**
- Product detection (bash probes against local files and git config)
- All conversational detail collection
- Issue body assembly
- `gh` availability check

**Sent to Anthropic (Claude API):**
- Your answers during detail collection and the formatted issue body — standard Claude Code session behavior, same as any LLM interaction in Claude Code

**Sent to GitHub (on explicit confirmation only):**
- Issue title, body, and label via `gh issue create`, which uses the GitHub REST API
- Reporter stores no credentials; it delegates to your existing `gh` auth session

**No telemetry. No analytics. No Reporter-specific network calls beyond `gh issue create`.**

## Limitations

- Works only with heurema GitHub repositories; detection logic and submission target are hardcoded to the `heurema` org
- Requires an active `gh` auth session for direct submission; without it, submission is manual via the clipboard fallback
- Interactive only — runs inside a Claude Code session, not in scripts or CI
- The clipboard fallback requires `pbcopy` (macOS) or `xclip`/`xsel` (Linux); if none are available, the body is printed to chat
- No deduplication: running `/report` twice with the same content creates two separate issues
