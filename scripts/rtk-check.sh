#!/usr/bin/env bash
# Verifies rtk will actually rewrite bash commands in an OpenCode session.
#
# Run this from OpenCode's shell tool, not a login shell: the plugin resolves rtk
# from OpenCode's own PATH, so this script must inherit that PATH to test what the
# plugin will really see.
set -u

fail=0
CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RTK_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/rtk/config.toml"

ok()   { printf '  ok    %s\n' "$1"; }
bad()  { printf '  FAIL  %s\n' "$1"; fail=1; }

echo "rtk preconditions"

# 1. Binary reachable from this PATH.
if command -v rtk >/dev/null 2>&1; then
  ok "rtk on PATH: $(command -v rtk) ($(rtk --version 2>/dev/null | head -1))"
else
  bad "rtk not on PATH — the plugin disables itself for the whole session"
fi

# 2. Session-wide kill switch.
if [ -n "${RTK_DISABLED:-}" ]; then
  bad "RTK_DISABLED is set in the OpenCode environment ($RTK_DISABLED) — rewriting is off"
else
  ok "RTK_DISABLED unset"
fi

# 3. The subcommand the plugin probes for.
if rtk hook opencode --help >/dev/null 2>&1; then
  ok "rtk hook opencode available"
else
  bad "this rtk lacks 'hook opencode' — the plugin disables itself"
fi

# 4. An actual rewrite, which is the only proof the chain works end to end.
rewrite="$(rtk hook opencode 'ls -la' 2>/dev/null)"
if printf '%s' "$rewrite" | grep -q '"command"[[:space:]]*:[[:space:]]*"rtk'; then
  ok "rewrite probe: 'ls -la' -> $(printf '%s' "$rewrite" | sed 's/.*"command"[[:space:]]*:[[:space:]]*"//; s/"[[:space:]]*}$//')"
else
  bad "rewrite probe returned no rewrite for 'ls -la' (got: ${rewrite:-empty})"
fi

# 5. Telemetry must stay off.
if [ -f "$RTK_CONFIG" ] && grep -qE '^enabled[[:space:]]*=[[:space:]]*false' "$RTK_CONFIG"; then
  ok "telemetry disabled in $RTK_CONFIG"
else
  bad "telemetry not disabled in $RTK_CONFIG (rtk telemetry disable)"
fi

# 6. No command exemptions.
if [ -f "$RTK_CONFIG" ] && grep -qE '^exclude_commands[[:space:]]*=[[:space:]]*\[\]' "$RTK_CONFIG"; then
  ok "no excluded commands"
else
  bad "hooks.exclude_commands is not empty — some commands bypass rtk"
fi

# 7. The plugin is still registered in the config.
if grep -q 'plugins/rtk.ts' "$CONFIG_DIR/opencode.json"; then
  ok "plugins/rtk.ts registered in opencode.json"
else
  bad "plugins/rtk.ts missing from opencode.json 'plugins'"
fi

echo
if [ "$fail" -ne 0 ]; then
  echo "rtk is NOT fully active — see the FAIL lines above"
  exit 1
fi
echo "rtk active: every bash command is offered to rtk (it still passes through when"
echo "a rewrite would change an OpenCode permission verdict, or if rtk errors/times out)"
