# Stack — English

<div align="center">

**Personal AI development environment for macOS: human + AI assistant in OpenCode.**
MCP servers, skills, CLI tools and office apps — one command to attach to a project, one command to update.

[🇷🇺 Русский](README.md) · **English**

</div>

---

## Why

Research and development require computation (Wolfram, Julia), visualization (ParaView, Manim), web research (Firecrawl), document deliverables (Word/Excel/PowerPoint/PDF) and UI mockups (FigCraft) — **in one place, driven by an AI agent**. The stack assembles official open-source tools and attaches them to OpenCode through every available channel: **MCP servers** (interactive compute and editing), **skills** (step-by-step agent workflows), **headless CLIs** (scripted commands without a window) and **control CLI scripts** (checks, updates, expiry tracking) — available **only in projects where it is explicitly attached**: the global OpenCode config stays empty.

| Principle | Meaning |
|---|---|
| Project-scoped | The stack activates only in projects it is attached to |
| Single source | Config template, skill lists and the repo map are edited in one place and spread by scripts |
| Freshness | `update-all.sh` updates everything and tracks license/subscription expiry |
| Portability | Paths via `{env:HOME}`; a fresh machine = `git clone` + `setup.sh` |
| Routing | Local stack traffic always direct; external web via the configured ISP proxy (`proxy.sh`) |

## Repo structure

```
~/stack/
├── README.md / AGENTS.md / STACK.md / workflow.txt
├── setup.sh                     # Install on a clean macOS (12 steps)
├── update-all.sh                # Update everything (13 steps) + expiry checks
├── check-all.sh                 # Health check
├── new-project.sh · sync-agents.sh · gen-opencode-config.sh
├── sync-aris.sh · consolidate-skills.sh · craft-install.sh
├── apply-first-start.sh · first-start.template.txt
├── proxy.sh · chrome-version.sh · check-wolfram-license.sh
├── projects.txt · aris-skills.txt
├── skills/ · skills-store/ (60 skills) · craft-cli/ · craft-downloads/
├── WolframLanguage/
└── cloned repos: paraview-mcp · manim-mcp · julia-mcp · tldraw-mcp
                  aris-research-repo · WolframLanguageForJupyter
```

## Manual steps

`setup.sh` automates everything via official brew casks (Wolfram Engine, ParaView, MacTeX, tldraw Desktop) and the official OpenCode tap. Only three things stay manual:

| Step | How |
|---|---|
| First-start form | `cp first-start.template.txt first-start.txt` → fill → `bash apply-first-start.sh` |
| Wolfram activation | `wolframscript` — sign in with a Wolfram ID (renew every ~40 days) |
| Firecrawl auth *(optional)* | `firecrawl login --browser` — an account is required; free tier is enough |

## Quick start

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh        # 12 steps: brew+casks, repos, venvs, CLIs, skills, configs
```

## What's inside

- **13 CLI tools**: setup, update-all (13 steps + expiry tracking), check-all, new-project, sync-agents, gen-opencode-config (10 MCP), sync-aris, consolidate-skills, craft-install, apply-first-start, proxy.sh (env + CLI), chrome-version, check-wolfram-license
- **10 MCP servers**: Wolfram, julia, manim, ParaView, tldraw + office Craft Apps: wordcraft (.docx), gridcraft (.xlsx), deckcraft (.pptx), pdfcraft (.pdf), figcraft (UI design)
- **5 Craft Apps** ([ArtCraft](https://getartcraft.com), open-source Rust; GUI via `craft-install.sh`, alpha-quality — keep backups of important documents)
- **60 skills** (Firecrawl 37, ARIS 14, standalone 8, tldraw-offline) — visible only in attached projects
- **6 VS Code extensions** installed automatically

## Attaching to a project

```bash
~/stack/new-project.sh ~/work/my-project
```
A project receives `AGENTS.md` (agent instructions) and `.opencode/opencode.json` (10 MCP + skills). Manual edits to the project config are overwritten on every sync — edit the template in `gen-opencode-config.sh` instead. `AGENTS.md` content outside the `STACK:START/END` markers is preserved.

## Usage

| Task | Command |
|---|---|
| Update everything | `cd ~/stack && bash update-all.sh` |
| Health check | `bash ~/stack/check-all.sh` |
| Attach a project | `~/stack/new-project.sh <path>` |
| Sync projects | `bash ~/stack/sync-agents.sh` |
| Update Craft Apps | `bash ~/stack/craft-install.sh` |
| Network status/test | `bash ~/stack/proxy.sh status` · `test` |
| Expiry: proxy / Wolfram | `proxy.sh expiry` · `check-wolfram-license.sh` |
| Firecrawl credits | `firecrawl credits` |

OpenCode v2 hot-reloads configs (`/reload`); restart it after updating components themselves (MCP binaries, venvs, skills).

For AI agents: start from [`AGENTS.md`](AGENTS.md). Full docs: [`STACK.md`](STACK.md) (Russian). Git rules: [`workflow.txt`](workflow.txt). Contributing: [`CONTRIBUTING.md`](CONTRIBUTING.md).
