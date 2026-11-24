<div align="center">

<img src="assets/painting.png" alt="Stack" width="100%">

</div>

**A personal AI development environment for macOS: a human working alongside an AI assistant in [OpenCode](https://opencode.ai).**

<h2 align="center">🧠 Why</h2>

Research and development need many things at once: computation, data visualization, web research, deliverables in familiar office formats, interface mockups — **in one place, driven by an AI agent**. The stack assembles official open-source tools and attaches them to OpenCode through every available channel: **MCP servers** (interactive compute and editing), **skills** (step-by-step agent workflows), **headless CLIs** (scripted commands without a window) and **control CLI scripts** (checks, updates, expiry tracking) — and it is available **only in projects where it is explicitly attached**: the global OpenCode config stays empty, and outside those projects the agent sees none of it.

<div align="center">

| Principle | Meaning |
|:---:|:---:|
| **Project-scoped** | The stack activates only in projects it is attached to |
| **Single source** | The config template, skill lists and the repo map are edited in one place and spread by scripts |
| **Freshness** | `update-all.sh` updates everything — brew → Apple CLT/system → repos → venvs → skills → VS Code extensions → Julia → Wolfram → Craft Apps — and tracks license/subscription/credit expiry |
| **Portability** | Paths in configs go through `{env:HOME}`; a fresh machine = `git clone` + `setup.sh` |
| **Routing** | Local stack traffic always goes direct; external web traffic goes through the configured ISP proxy (`proxy.sh`, personal values in `~/.stack-secrets.sh`) |

</div>

> [!TIP]
> **Integration-friendly — the stack is a layer, not a box.** Attach it to any existing project and keep working your way. Add anything new — your own tools, other MCP servers, skills, even C++ support — into *your project*, or extend *the stack itself*: the AI assistant can wire new instruments into either. Nothing here is a static set — the stack grows with whatever you want to add.

<h2 align="center">🗂️ Table of contents</h2>

<div align="center">

[🗺️ Repository structure](#-repository-structure)<p>
[🖐 Manual steps](#-manual-steps)<p>
[🚀 Quick start](#-quick-start)<p>
[📦 What's inside](#-whats-inside)<p>
[☎️ Attaching to a project](#-attaching-to-a-project)<p>
[🤝 Files: human vs AI agent](#-files-human-vs-ai-agent)<p>
[🛠 Usage](#-usage)

</div>

<h2 align="center">🗺️ Repository structure</h2>

<div align="center">

All `*.sh` are CLI tools (run: `bash <path>/<name>.sh`)

</div>

```
<path>/                # wherever you cloned the stack
├── README.md                    # This file
├── AGENTS.template.md           # Agent instructions source ({{STACK}} placeholder)
├── AGENTS.md                    # (generated locally, gitignored)
├── STACK.md                     # Full documentation: keybinds, examples (Russian)
├── workflow.txt                 # Git workflow rules
│
├── setup.sh                     # Install on a clean macOS (12 steps)
├── update-all.sh                # Update everything (15 steps) + expiry tracking
├── check-all.sh                 # Health check
│
├── new-project.sh               # Attach a project (any folder, git or not)
├── detach-project.sh            # Detach the stack from a project
├── export-personal.sh           # Collect personal files (registry, form, secrets) for backup/migration
├── sync-agents.sh               # AGENTS.md + configs → all projects (rewrites paths if the stack moved)
├── gen-opencode-config.sh       # .opencode/opencode.json generator (10 MCP)
├── sync-aris.sh                 # ARIS skills → skills-store
├── consolidate-skills.sh        # Assemble skills-store + clean global dirs
├── craft-install.sh             # Install/update Craft Apps (GUI)
├── apply-first-start.sh         # First-start form → personal configs
├── proxy.sh                     # Network: env proxy + CLI (status/expiry/git/test)
├── chrome-version.sh            # Chrome version pinned by tldraw
├── check-wolfram-license.sh     # Wolfram license expiry
│
├── first-start.template.txt     # First-start form template
├── projects.template.txt        # Project registry template (projects.txt is personal)
├── aris-skills.txt              # List of 14 ARIS skills
├── skills/                      # 8 standalone skills (source)
├── skills-store/                # Assembled 60 skills (gitignored)
├── craft-cli/                   # Headless CLIs of the Craft Apps (gitignored)
├── craft-downloads/             # DMG cache of installers (gitignored)
├── assets/                      # Banner (painting.png) + editable painting.tldraw
├── WolframLanguage/             # Custom Wolfram packages
│
└── paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ ·      # cloned
    aris-research-repo/ · WolframLanguageForJupyter/             # repos
```

<h2 align="center">🖐 Manual steps</h2>

<div align="center">

**You don't memorize any of them — the AI agent leads the setup.**

</div>

<div align="center">

| Step | Who does it |
|:---:|:---:|
| First-start form (proxy, git identity, Wolfram ID) | **The agent asks in chat, fills the form, applies it** |
| Craft Apps GUI · Wolfram activation · Firecrawl login *(optional)* | The agent runs the scripts; you only confirm in the browser/enter a password when macOS asks |
| Project attach | The agent runs `new-project.sh` for every folder you name |

</div>

> [!NOTE]
> `check-all.sh` verifies the presence of every component — ✅ or ❌ per row.

<h2 align="center">🚀 Quick start</h2>

```shell
git clone https://github.com/custom-opencode/stack.git <path>
cd <path>                                                        # the folder you cloned into
opencode
```

> [!NOTE]
> The clone destination is **your choice** — the stack is path-agnostic: every script finds its own root, and project configs get absolute paths at attach time. `<path>` = the folder you cloned the stack into.

That's the whole start. In the fresh clone the agent is "bare" (no stack MCPs yet) — its first action is running `setup.sh` itself (approving that one command is the only click you make; you may be asked for the macOS password where the system requires it). Then the agent leads the rest of the setup: asks for your proxy and git identity in chat, fills the first-start form, installs the Craft Apps GUI, checks the Wolfram license, attaches your projects — and runs `check-all.sh` so you see every ✅. All you ever do interactively: approve, type the password, confirm browser logins. After the setup — restart OpenCode in each project folder so MCP servers and skills load.

The setup procedure the agent follows lives in `AGENTS.template.md` — nothing to memorize.

<h2 align="center">📦 What's inside</h2>

### Terminal and CLI tools

<div align="center">

Everything is installed automatically by `setup.sh`

</div>

<div align="center">

| What | How |
|:---:|:---:|
| Python 3.12 · Node.js · gh · ffmpeg · juliaup | `brew install` |
| Wolfram Engine · ParaView · MacTeX · tldraw Desktop | `brew install --cask` |
| OpenCode | `brew install anomalyco/tap/opencode-v2` |
| `firecrawl-cli` · `tldraw-cli` | `npm install -g` |
| `manim-env` — Manim + ManimGL | pip venv |
| `jupyter-env` — JupyterLab, numpy, pandas, sympy, plotly… | pip venv |
| `paraview-mcp-env`, `julia-mcp-env` — MCP SDK | pip venv |
| Playwright Chromium · Puppeteer Chrome *(headless, version auto)* | `npx … install` |
| Julia + 20 packages | `juliaup` + `Pkg.add` |
| Wolfram AgentTools (paclet) | `PacletInstall` — if Wolfram Engine is already installed, otherwise at the first `update-all.sh` |
| 6 external repositories | `git clone --depth 1` |
| `tldraw-mcp` build | `npm install && npm run build` |
| Craft Apps headless CLIs ×5 | GitHub releases → `<path>/craft-cli/` |

</div>

> [!TIP]
> **Manim vs ManimGL:** `manim` (community) renders headless and is what the MCP server uses. `manimgl` (3Blue1Brown) is an interactive GUI tool for you — no MCP uses it.

### MCP servers (10)

<p align="center">

Configs are generated automatically (`gen-opencode-config.sh`); for ParaView start the GUI + pvserver using the workflow from `STACK.md`:

</p>

<div align="center">

| Server | What it does |
|:---:|:---:|
| **Wolfram** | Wolfram Language computation (via AgentTools) |
| **julia** | Persistent Julia REPL sessions |
| **manim** | Headless animation rendering to video |
| **ParaView** | 3D data visualization (via TCP bridge) |
| **tldraw** | Whiteboard canvas, 30+ tools |
| **wordcraft** | Word documents: .docx, citations APA/MLA/Chicago/IEEE, Zotero |
| **gridcraft** | Excel: .xlsx, 500+ functions, PivotTables, charts |
| **deckcraft** | PowerPoint: .pptx, themes, Morph, PDF/GIF export |
| **pdfcraft** | PDF: merge, split, protect, comments |
| **figcraft** | UI design: frames, auto-layout, prototypes |

</div>

### Craft Apps (5)

<p align="center">

Native macOS apps by [ArtCraft](https://getartcraft.com) (open source, pure Rust) — each with a headless CLI and an MCP. The GUI is installed/updated by a script:

</p>

```shell
$ bash <path>/craft-install.sh
```

<div align="center">

| App | Official status |
|:---:|:---:|
| WordCraft · GridCraft · DeckCraft | In development |
| PdfCraft · FigCraft | Early alpha |

</div>

> [!WARNING]
> All apps are pre-release: complex files from MS Office and .fig files open best-effort and may not look perfect — **keep backups of important documents**.

### VS Code extensions (6)

Installed automatically by `setup.sh` if the VS Code CLI (`code`) is present: `tldraw-org.tldraw-vscode` (.tldr), `ms-python.python` (.py), `ms-toolsai.jupyter` (.ipynb), `julialang.language-julia` (.jl), `wolframresearch.wolfram` (.wl), `james-yu.latex-workshop` (.tex).

### OpenCode skills (60)

<p align="center">

Assembled automatically (`consolidate-skills.sh`) into `<path>/skills-store/` and attached to projects via `skills` in the config — **outside projects the agent sees only OpenCode's built-in skills**.

</p>

<div align="center">

| Group | ~Count | Source |
|:---:|:---:|:---:|
| Firecrawl — web research, scraping, SEO | 37 | `firecrawl setup skills/build/workflows` |
| ARIS — research pipeline, papers, experiments | 14 | ARIS clone → `sync-aris.sh` |
| `tldraw-offline` — control of an open tldraw Desktop | 1 | installed by the app itself |
| Standalone — see the repo's `skills/` | 8 | this repository |

<details>
<summary><b>8 standalone skills, by name</b></summary>

| Skill | Purpose |
|:---:|:---:|
| `render-visual` | Polished PNG/SVG/PDF, slides, diagrams, GIF |
| `data-analysis` | EDA, data visualization, reports, hypotheses |
| `craft-office` | Office deliverables: Word/Excel/PowerPoint/PDF via Craft Apps |
| `deep-mind` | Deep critical thinking |
| `epistemic-rigor` | Anti-sycophancy, honest hypothesis evaluation |
| `grill-me` | Stress-testing plans and decisions |
| `dag-hallucination-detector` | Checking citations and facts |
| `aris-research-pipeline` | Full research pipeline (local-only) |

</div>

</details>

<h2 align="center">☎️ Attaching to a project</h2>

```shell
<path>/new-project.sh ~/work/my-project    # create new / register existing
```

<div align="center">

The project receives **two files**

</div>

<div align="center">

| File | Contents |
|:---:|:---:|
| `AGENTS.md` | Agent instructions: stack map, MCP tools, conventions |
| `.opencode/opencode.json` | `mcp` ×10 · `skills` → skills-store |

| Fact | Details |
|:---:|:---:|
| **Portability** | Paths in the config go through `{env:HOME}` — portable between machines |
| **Registry** | `<path>/projects.txt` is personal (gitignored, created from `projects.template.txt`) — one path per line |
| **Sync** | `bash <path>/sync-agents.sh` regenerates AGENTS.md + configs in all projects (part of `update-all.sh`, step 14); AGENTS.md content **outside** the `<!-- STACK:START/END -->` markers is preserved |
| **Config — no markers** | `.opencode/opencode.json` is regenerated **wholesale** on every sync / new-project: edit the template in `gen-opencode-config.sh`, not project configs |
| **Diagnostics — by running** | OpenCode v2 has no LSP: the agent gets code errors by running linters/compilers/tests directly (`bash -n`, `python`, `npm run build`, `pdflatex`) — honest build errors |
| **Outside projects** | No MCP, no skills; `~/.config/opencode/` holds only client settings |
| **Extensions — no plugins** | All extensions go through MCP servers (external processes) and skills (prompts); the config contains no `plugins` field |

</div>

<h2 align="center">🤝 Files: human vs AI agent</h2>

<p align="center">

You — in VS Code (the stack's extensions provide language servers: autocomplete and errors as you type), the agent — in OpenCode (via MCP/CLI and by running compilers/linters directly)

</p>

<div align="center">

| File | You — in VS Code | Agent — in OpenCode |
|:---:|:---:|:---:|
| `.tldr` | Draw on the canvas | tldraw MCP; render `tldraw export` |
| `.py` | Pylance | Run code; linters |
| `.sh` | Terminal: `bash -n` | `bash -n` + run |
| `.jl` | Julia LS | Run `julia` |
| `.ts` | Built-in TS | `npm run build` |
| `.ipynb` | Cells in the GUI | `jupyter` |
| `.tex` | Compile + PDF | `pdflatex` + read the log |
| `.wl` | Highlighting + wolframscript | wolframscript |
| `.docx` `.xlsx` `.pptx` `.pdf` | Craft Apps GUI | Craft Apps MCP/CLI (headless or live mode) |
| `.figcraft` | FigCraft | FigCraft MCP/CLI: frames, prototypes, PNG/SVG/PDF export |

</div>

<h2 align="center">🛠 Usage</h2>

<div align="center">

| Task | Command |
|:---:|:---:|
| **Update the whole stack** | `cd <path> && bash update-all.sh` — 15 steps, then `/reload` or an OpenCode restart |
| **Health check** | `bash <path>/check-all.sh` |
| **Attach a project** | `<path>/new-project.sh <project-path>` — any folder, git or not |
| **Detach a project** | `<path>/detach-project.sh <project-path>` — removes the config + registry entry, project files stay (works even if the folder is already gone) |
| **Sync + drop dead entries** | `bash <path>/sync-agents.sh --prune` — removes registry paths that no longer exist |
| **Back up personal data** | `bash <path>/export-personal.sh` — collects `projects.txt`, first-start form, `~/.stack-secrets.sh`, `~/skills` into one folder |
| **Sync projects** | `bash <path>/sync-agents.sh` |
| **Install/update Craft Apps** | `bash <path>/craft-install.sh` |
| **Network: status / test / git** | `bash <path>/proxy.sh status` · `test` · `git on\|off` |
| **Expiry: proxy / Wolfram** | `bash <path>/proxy.sh expiry` · `bash <path>/check-wolfram-license.sh` |
| **Firecrawl credits** | `firecrawl credits` |
| **Chrome version for tldraw** | `bash <path>/chrome-version.sh` |

</div>

> [!NOTE]
> OpenCode v2 hot-reloads configs (`/reload`); after updating the components themselves (MCP binaries, venvs, skills) an OpenCode restart is safer.

