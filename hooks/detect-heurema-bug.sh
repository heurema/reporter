#!/bin/bash
# PostToolUse hook: detect bugs in heurema CLI tools and plugin workflows.
# Fires after Bash calls. If a heurema tool error is detected,
# outputs a prompt for the agent to offer filing a GitHub issue.
#
# Receives JSON on stdin: {tool_name, tool_input, tool_output}
# stdout → injected as feedback to the agent (empty = silent)

set -euo pipefail

INPUT="$(cat)"

tool_name="$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)" || true
[ "$tool_name" = "Bash" ] || exit 0

command="$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)" || true
output="$(echo "$INPUT" | jq -r '.tool_output[:4000] // empty' 2>/dev/null)" || true

# --- Detect heurema product ---

PRODUCTS=(mycel nex jj-supersede watchdog-cli)
product=""

# Level 1: direct CLI invocation
for p in "${PRODUCTS[@]}"; do
  if echo "$command" | grep -qE "(^|[;&|/ ])${p}( |$)" 2>/dev/null; then
    product="$p"
    break
  fi
done

# Level 2: plugin workflow artifacts (.signum/, .delve/, etc.)
if [ -z "$product" ]; then
  for p in signum delve; do
    if echo "$command" | grep -qE "\.${p}/" 2>/dev/null; then
      product="$p"
      break
    fi
  done
fi

[ -n "$product" ] || exit 0

# --- Check for actual error ---

has_error=false

# Non-zero exit code (Claude Code wraps errors as "Exit code N")
if echo "$output" | grep -qE 'Exit code [1-9]' 2>/dev/null; then
  has_error=true
fi

# Panic / traceback (Rust or Python crash)
if echo "$output" | grep -qE 'panic(ked)?|thread.*panicked|Traceback \(most recent' 2>/dev/null; then
  has_error=true
fi

[ "$has_error" = "true" ] || exit 0

# --- Exclude false positives ---

# Version checks, existence probes, help
if echo "$command" | grep -qE 'command -v|which |--version|--help|2>/dev/null.*\|\|' 2>/dev/null; then
  exit 0
fi

# Test runs (intentional failures)
if echo "$command" | grep -qE 'cargo test|pytest|jest|npm test' 2>/dev/null; then
  exit 0
fi

# --- Emit agent instruction ---

# Extract short error (first 3 non-empty stderr lines)
short_error="$(echo "$output" | grep -iE 'error|panic|fatal|failed' | head -3)"

cat <<EOF
[auto-report] Detected failure in heurema/${product}.
Error: ${short_error}
Command: $(echo "$command" | head -1 | cut -c1-120)

If this is a genuine bug (not expected behavior), ask the user:
"Found a bug in ${product}. File a GitHub issue on heurema/${product}?"
If confirmed, use: gh issue create -R "heurema/${product}" --title "<concise title>" --body "<repro steps, expected vs actual, error output>"
EOF
