# Contributing

Thanks for wanting to improve the stack! Propose **anything** — bugs, ideas, customization, questions. The owner and the AI assistant review every proposal and help land it: if you don't write bash, just describe the problem in words — that's enough.

## How to propose (any way you like)

- **Issue** — simply write what doesn't work or what you'd like. This alone is enough; we'll take it from there.
- **PR** — if you're comfortable with git: fork → branch `fix/…` → changes → push → Pull Request. We'll review, guide and finish it together.
- **Any other form** — a sketch, a snippet, a screenshot, half an idea: open an issue and we'll turn it into a change.

## Contributor workflow

`workflow.txt` in the repo is the **author's personal** git flow — you don't need it. Any flow that ends in a PR works:

```
fork → branch (fix/… or feature/…) → commit → push → Pull Request
```

One commit per logical change is appreciated, but don't stress — we'll help untangle it.

## The few rules (they keep the stack safe for everyone)

These are what we check for any change — you can do it yourself or let us handle it:

1. **Idempotency** — running any script twice is safe
2. **No secrets in the repo** — templates only; personal values live in `~/.stack-secrets.sh` / `.zshrc`
3. **Path-agnostic** — every script locates its own root (`STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`); no hardcoded `$HOME/stack` in code. Project configs (`gen-opencode-config.sh`) bake absolute paths at generation time; `sync-agents.sh` rewrites them if the stack moves
4. **AGENTS.md is generated** — the committed source is `AGENTS.template.md` (with a `{{STACK}}` placeholder); `AGENTS.md` is a local render (gitignored). Edit the template, never the render
5. **Consistent docs** — counters (CLI/MCP/skills/steps) and commands match across README, `AGENTS.template.md`, STACK.md
6. **Project-scoped** — no changes that make the stack global

## Code of Conduct

Not set up — for a personal repository it isn't required. If the project grows, GitHub enables the standard one in a single click.
