# Contributing — English

[🇷🇺 Русский](CONTRIBUTING.md) · **English**

Thanks for wanting to improve the stack! Propose **anything** — bugs, ideas, customization, questions. The owner and the AI assistant will review every proposal and help land it: if you don't write bash, just describe the problem in words.

## How to propose

- **Issue** — simply write what doesn't work or what's missing. That's enough.
- **PR** (if you're comfortable with git): fork → branch `fix/...` → changes → push → Pull Request. We'll review, guide and finish it together.
- Not sure whether it's a bug or a question — open an issue and we'll figure it out.

## What we check for every change

| Check | Command |
|---|---|
| Script syntax | `bash -n <script>.sh` |
| Nothing broke | `bash ~/stack/check-all.sh` |
| Docs consistency | counters (CLI/MCP/skills/steps) match in README, AGENTS.md, STACK.md |
| Idempotency | running a script twice is safe |

## Good to know

- The stack is **personal and authored**, but any proposal is welcome: from a typo to a new tool
- Secrets never enter the repository (templates yes, values no)
- Personal paths use `{env:HOME}`; private data lives in `~/.stack-secrets.sh` and `.zshrc`
- Full git workflow: `workflow.txt`
