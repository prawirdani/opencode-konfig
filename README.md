# opencode-config

Global [OpenCode](https://opencode.ai) v2 configuration for a single machine. It
holds the model/provider setup, agent presets, MCP servers, plugins, skills and
slash commands.

Secrets never live here. Every credential is referenced by path from
`~/.secrets/`, so this repo is safe to publish.

## Personal config

One person's daily driver, on Linux, tuned over time. The opinions are the point.

- **Voice.** Replies default to `caveman`: answer first, no ceremony, every
  technical fact kept. `/caveman ultra` cuts to fragments, `/megacave` goes to
  Classical Chinese. `AGENTS.md` enforces it; `plugins/caveman` tracks it.
- **Coding rule.** Ponytail at full level. Smallest change that fully solves the
  task; no abstraction nobody asked for; name what got skipped.
- **Tabs, width 100.** `biome.json` is not up for debate. The theme is `orng`,
  because orange is the right answer.
- **Presets named for moods.** `main` when Opus should drive, `mocin` for a cheap
  all-`deepseek-flash` fleet, `gretong` when only free models are allowed.
- **Free models where the work is invisible.** Titles, summaries, compaction and
  subagent legwork run free. Paid reasoning is spent on judgment, not plumbing.
- **Secrets stay out of git.** No exceptions, no "just this once".

If that reads like a personality, it is one, and it is load-bearing: the config
is the argument.

## Layout

| Path | Purpose |
| --- | --- |
| `opencode.json` | Main config: providers and models, MCP servers, plugins, permissions, formatters, disabled agents, compaction |
| `cli.json` | TUI settings: theme, sidebar, diffs, animations |
| `oh-my-opencode-slim.json` | Agent presets for the `oh-my-opencode-slim` plugin, plus which preset is active |
| `oh-my-opencode-slim/` | Prompt append files the plugin merges into the orchestrator and explorer agents |
| `agents/` | Local agent prompts (`cavecrew-builder`, `cavecrew-investigator`, `cavecrew-reviewer`) |
| `commands/` | Slash commands (`/commit`, `/pr`, `/caveman*`, `/megacave`, `/ultracave`) |
| `plugins/` | Repo-local plugins (`caveman`, `rtk.ts`) |
| `skills/` | 24 vendored skills |
| `skills-lock.json` | Source and hash record for the skills that were installed from GitHub |
| `AGENTS.md` | Global agent instructions (terse "caveman" response style) |
| `biome.json` | Biome formatting rules for this repo's own JS/TS/JSON |
| `service.json` | Local server password. Gitignored — never commit it |

## Tooling

### Provider and models

One provider, `9router`, an OpenAI-compatible proxy (`aisdk:@ai-sdk/openai-compatible`).
Its endpoint and API key are read from files:

```jsonc
"baseURL": "{file:~/.secrets/ninerouter-base-url}",
"apiKey": "{file:~/.secrets/ninerouter-key}"
```

| Model | Context / output | Variants |
| --- | --- | --- |
| `9router/ds/deepseek-flash` | 1,048,576 / 393,216 | none |
| `9router/cc/claude-opus-4-8` | 1,000,000 / 128,000 | `low`, `medium`, `high`, `xhigh`, `max` |
| `9router/cc/claude-fable-5` | 1,000,000 / 128,000 | `low`, `medium`, `high`, `max` |

Internal agents `title`, `summary` and `compaction` run on a free model
(`opencode/deepseek-v4.1-flash-free`) so they never consume proxy quota.
`explore` and `general` are disabled.

### Agent presets

`oh-my-opencode-slim.json` defines three presets; the top-level `"preset"` key
selects the active one.

| Preset | orchestrator | oracle | explorer | designer | fixer |
| --- | --- | --- | --- | --- | --- |
| `main` | `cc/claude-opus-4-8` (`high`) | `cc/claude-opus-4-8` (`max`) | `opencode/deepseek-v4.1-flash-free` | `ds/deepseek-flash` | `ds/deepseek-flash` |
| `mocin` | `ds/deepseek-flash` | `ds/deepseek-flash` | `ds/deepseek-flash` | `ds/deepseek-flash` | `ds/deepseek-flash` |
| `gretong` *(active)* | `opencode/deepseek-v4.1-flash-free` | `opencode/nemotron-3-ultra-free` | `opencode/nemotron-3.5-lightning-free` | `opencode/glm-5.3-flash-free` | `opencode/deepseek-v4.1-flash-free` |

Model ids outside `9router/` come from the `opencode` provider and are free.
Switch presets by editing `"preset"` and reloading OpenCode.

### MCP servers

| Server | Launch | Notes |
| --- | --- | --- |
| `playwright` | `npx -y @playwright/mcp@0.0.83 --headless` | Pinned version, headless. Needs a Playwright browser cache |
| `tavily` | `tavily-mcp` | Key injected from `{file:~/.secrets/tavily-key}` |

`context7` and `gh_grep` ship inside the `oh-my-opencode-slim` plugin and are
granted to the explorer agent by the presets, not declared here.

### Plugins

| Plugin | Source | Notes |
| --- | --- | --- |
| `oh-my-opencode-slim` | npm | Orchestrator/subagent architecture, presets, built-in skills |
| `@dietrichgebert/ponytail` | npm | Lazy-senior-dev coding rules and reviews |
| `./plugins/caveman` | this repo | Terse response mode plus its slash commands |
| `./plugins/rtk.ts` | this repo | Thin shim that delegates command rewriting to the `rtk` binary; inert when `rtk` is not on `PATH` |

npm plugins are fetched into `~/.cache/opencode/packages` on first run, so the
first start needs network access. They are not vendored here.

### Skills

Vendored in `skills/`, installed from these sources:

- **`JuliusBrussee/caveman`** — `caveman`, `caveman-commit`, `caveman-compress`, `caveman-help`, `caveman-review`, `caveman-stats`, `cavecrew`, plus `megacave` and `ultracave` (present locally, absent from `skills-lock.json`).
- **`mattpocock/skills`** — `code-review`, `codebase-design`, `grilling`, `grill-me`, `grill-with-docs`, plus `tdd`, `diagnosing-bugs`, `to-spec`, `implement-spec`, `triage`, `research`, `handoff`, `improve-codebase-architecture`, `writing-for-agents` (the last nine are not recorded in `skills-lock.json`).
- **`impeccable`** v4.0.4 — vendored frontend design and audit skill.

The plugins contribute further skills at runtime (`ponytail`, `deepwork`,
`step-back`, `simplify`, `worktrees`, `reflect`, `clonedeps`, `codemap`,
`verification-planning`, the `context-mode` family). Those load from the plugin
cache and are not part of this repo.

### Guardrails

- **Denied:** `rm -rf *`, `git push --force*`, `git reset --hard*`, `curl * | sh*`.
- **Asks first:** reads of `**/.secrets/**` and `**/.env*`.
- **Watcher** ignores `node_modules`, `.git`, `dist`, `build`, `target`, `.next`.
- **Formatters:** `goimports` for Go, `biome` for JS/TS/JSON/CSS; LSP enabled.
- **Compaction** is automatic, keeping 15,000 tokens.

## Prerequisites

| Requirement | Version used here | Needed for |
| --- | --- | --- |
| [OpenCode](https://opencode.ai) | v2.1.2 | everything; this config is v2-only |
| Bun | 1.4.2 | plugin loading, `bunx` formatter |
| Node.js + npm | v24.10.0 | `npx`/`bunx` MCP launches, global tools |
| `tavily-mcp` | 0.2.22 | the tavily MCP server |
| `typescript-language-server` | 6.0.2 | TS/JS LSP diagnostics |
| `typescript` | 7.0.2 | `tsc` used by the TS language server |
| `goimports` | — | optional; the Go formatter |
| `rtk` | — | optional; command-rewrite savings in `plugins/rtk.ts` |
| `rg` | 14.1.0 | search. OpenCode falls back to its own bundled copy (15.1.0) if absent |
| Playwright browsers | chromium | the playwright MCP server |
| Reachable 9router proxy | — | every `9router/*` model |

Secrets, all mode `600`, none tracked:

| File | Contents |
| --- | --- |
| `~/.secrets/ninerouter-base-url` | Proxy base URL, e.g. `https://host:port/v1` |
| `~/.secrets/ninerouter-key` | Proxy API key |
| `~/.secrets/tavily-key` | Tavily API key (`tvly-…`) |

## Setup

```bash
# 1. Secret files (mode 600, never committed)
mkdir -p ~/.secrets && chmod 700 ~/.secrets
printf '%s' 'https://your-proxy-host:port/v1' > ~/.secrets/ninerouter-base-url
printf '%s' 'your-proxy-key'                 > ~/.secrets/ninerouter-key
printf '%s' 'tvly-your-tavily-key'           > ~/.secrets/tavily-key
chmod 600 ~/.secrets/*

# 2. Global tools
npm i -g tavily-mcp typescript-language-server typescript

# 3. Playwright browsers for the MCP server
npx playwright install chromium

# 4. Verify the config resolves (baseURL must not be empty)
opencode debug config | grep -A2 '"settings"'
opencode debug agents            # shows the active preset's model per agent
```

Restart OpenCode after changing plugin entries, MCP servers or preset files.

## Secrets policy

- Config references secrets only as `{file:~/.secrets/…}`. `git ls-files` must
  never show anything from `~/.secrets/`.
- **Use `{file:…}`, not `{env:…}`, for anything custom.** OpenCode v2.1.2
  resolves `{env:VAR}` for a small set of built-ins only: `{env:HOME}` works,
  while `{env:NINEROUTER_BASE_URL}` resolved to `""` even with the variable
  exported.
- A missing or unreadable secrets file resolves to an empty string, not an
  error. Symptom: `Route.model(openai-compatible-chat) requires an endpoint
  baseURL`, or a keyless MCP server. Re-run `opencode debug config` after moving
  the config to a new machine.

## Repo hygiene

`.gitignore` covers `node_modules/`, `service.json`, `*.bak`, `.caveman-*` and
`.ponytail-*`.

History has been scanned for credential material: no API keys, tokens, private
keys, JWTs, `.env` files or proxy addresses appear in any commit.
