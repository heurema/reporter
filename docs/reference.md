# Reporter Reference

## Command

### /report [type]

File a bug report, feature request, or question for a heurema product.

**Arguments**

| Argument | Required | Values | Description |
|----------|----------|--------|-------------|
| `type` | No | `bug`, `feature`, `question` | Issue type. If omitted, the command asks interactively. |

The command also triggers on natural-language phrases: "report a bug", "file an issue", "report issue".

**Labels applied**

| Type | GitHub label |
|------|-------------|
| `bug` | `bug` |
| `feature` | `enhancement` |
| `question` | `question` |

If the label does not exist in the target repository, Reporter retries the submission without `--label`.

---

## Usage Scenarios

### Scenario 1: Filing a bug

You are working in a project that uses the `anvil` plugin and encounter unexpected behaviour.

```
/report bug
```

Reporter detects the product from the git remote or `plugin.json`, then asks one question at a time:

```
Give this issue a short title:
> /anvil:check silently skips validate_hooks when plugin.json is missing jq field

Describe the bug — what happened?
> Running /anvil:check with a hook script that uses jq but has no jq dependency
> declared in plugin.json produces no warning and exits with PASS.

What did you expect to happen? (optional — press Enter to skip)
> validate_hooks should emit a WARN when jq is used but not declared.

Steps to reproduce? (optional)
> 1. Create a plugin with a hook script that uses jq
> 2. Remove the jq dependency from plugin.json
> 3. Run /anvil:check

How often does this happen? Always, sometimes, or one-off? (optional)
> always
```

Reporter silently captures environment info, then previews the full issue:

```
Here's the issue that will be created. Look good?

Title: /anvil:check silently skips validate_hooks when plugin.json is missing jq field

## Bug Report
...

## Environment
OS: Darwin 25.3.0
Shell: /bin/zsh
Claude Code: 1.2.3

Submit / Edit / Cancel
```

On confirmation:

```
Issue created: https://github.com/heurema/anvil/issues/42
```

---

### Scenario 2: Requesting a feature

```
/report feature
```

Reporter asks:

```
Give this issue a short title:
> Add --fix flag to /anvil:check to auto-correct safe violations

What feature do you want?
> /anvil:check --fix would auto-rewrite @-syntax violations and re-run the validator.

Why is this useful? What problem does it solve? (optional)
> Convention violations like wrong injection syntax are mechanical fixes.
> Having to fix them manually after every check adds friction.
```

The issue is filed with the `enhancement` label.

---

### Scenario 3: Asking a question

```
/report question
```

```
Give this issue a short title:
> Difference between anvil-reviewer and /anvil:check

What's your question?
> Does anvil-reviewer replace /anvil:check or are they meant to be used together?

Any context? What are you trying to do? (optional)
> [Enter]
```

Filed with the `question` label.

---

### Scenario 4: Submitting without gh CLI

Reporter runs through normal collection and preview. On confirmation, if `gh` is unavailable or unauthenticated:

```
Issue body copied to clipboard.

Open this URL to submit manually:
https://github.com/heurema/anvil/issues/new?template=bug_report.md

Paste the clipboard contents into the issue body field.
```

---

### Scenario 5: Product not auto-detected

You run `/report` outside a heurema project directory. Reporter prompts:

```
Which heurema product is this about?
- proofpack
- signum
- anvil
- herald
- skill7.dev
- teams-field-guide
- Other (let them type)
```

Reporter proceeds with the chosen or typed product name.

---

## Output Format

**Successful submission**

```
Issue created: https://github.com/heurema/<product>/issues/<number>
```

**Clipboard fallback**

```
Issue body copied to clipboard.
Open this URL to submit manually:
https://github.com/heurema/<product>/issues/new?template=<bug_report|feature_request|question>.md
```

**Aborted**

```
[No message — Reporter simply stops.]
```

---

## Environment Section Format

Every submitted issue includes an `## Environment` section appended automatically with output from:

```bash
echo "OS: $(uname -s) $(uname -r)"
echo "Shell: $SHELL"
echo "Claude Code: $(claude --version 2>/dev/null || echo 'unknown')"
```

Example:

```
## Environment
OS: Darwin 25.3.0
Shell: /bin/zsh
Claude Code: 1.2.3
```

---

## Troubleshooting

**"Which heurema product is this about?" — unexpected prompt**

Reporter could not match the git remote, `plugin.json`, or `pyproject.toml` to a heurema repository. This is expected outside a heurema project directory. Choose from the list or type the product name.

**"gh auth status: not logged in"**

Run `gh auth login` to authenticate. Reporter will use direct submission on the next run. Until then, the clipboard fallback is used automatically.

**Clipboard fallback not working on Linux**

Install `xclip` (`apt install xclip`) or `xsel` (`apt install xsel`). If neither is available, Reporter prints the issue body in the chat window for manual copying.

**Issue filed against the wrong product**

Cancel at the preview step and run `/report` again. When Reporter asks "Which heurema product is this about?", specify the correct product.

**Two identical issues created**

Reporter has no deduplication. Close the duplicate on GitHub manually. A comment on the original referencing the duplicate before closing helps maintainers track it.

**`claude --version` shows "unknown" in environment section**

This happens when the `claude` binary is not on `PATH` in the shell environment that Claude Code uses. The field is included with value "unknown" rather than omitted. It does not affect submission.
