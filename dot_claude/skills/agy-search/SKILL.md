---
name: agy-search
description: Web search via the `agy` CLI. Use this skill whenever a web search is needed instead of the builtin WebSearch tool.
---

## Agy Search

`agy` is the CLI used for web search (formerly `gemini`).

**When this skill is invoked, ALWAYS use `agy` for web search instead of the builtin `WebSearch` tool.**

Run web search non-interactively via the Bash tool:

```bash
agy --prompt "WebSearch: <query>"
```

Notes:
- `--prompt` (alias `-p` / `--print`) runs a single prompt non-interactively and prints the response.
- If a search needs more time, pass `--print-timeout` (default `5m0s`).
