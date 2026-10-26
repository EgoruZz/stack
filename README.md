# Stack

Personal development toolkit for macOS. MCP servers, AI skills, scripts, and everything needed for a full-featured AI-augmented development environment.

## Quick Start

```bash
git clone https://github.com/EgoruZz/stack.git ~/stack
cd ~/stack
bash setup.sh
```

## What Gets Installed

| Component | Source | Description |
|-----------|--------|-------------|
| Python 3.12 | Homebrew | Runtime for Manim, Jupyter, MCP servers |
| Node.js | Homebrew | Runtime for tldraw MCP |
| Julia | Homebrew | Scientific computing language |
| Manim + ManimGL | pip | Animation engine (community + OpenGL) |

> **Manim vs ManimGL:** `manim` (community edition) is the primary engine — used by the MCP server for headless rendering to video files. `manimgl` (3Blue1Brown) is a separate interactive tool with its own GUI window; it is **not** used by any MCP server. Use `manim` for automation and `manimgl` for interactive development and live preview.
| JupyterLab | pip | Interactive notebooks |
| Firecrawl CLI | npm | Web scraping and research (28 skills) |
| tldraw CLI | npm | Whiteboard diagram export |
| 5 MCP servers | git clone | Wolfram, Julia, Manim, ParaView, tldraw |
| 51 skills | npm + git + local | AI skills for OpenCode |

### MCP Servers

| Server | What it does |
|--------|-------------|
| **Wolfram** | Wolfram Language computation (via AgentTools) |
| **Julia** | Persistent Julia REPL sessions |
| **Manim** | Headless animation rendering |
| **ParaView** | 3D visualization pipeline (via TCP bridge) |
| **tldraw** | Whiteboard canvas with 30+ tools |

### Skills (51 total)

- **28 Firecrawl** — web research, scraping, SEO, lead gen, market research
- **14 ARIS** — research pipeline, paper writing, experiment planning
- **1 tldraw-skill** — whiteboard diagram generation
- **8 standalone** — render-visual, data-analysis, xlsx, deep-mind, epistemic-rigor, grill-me, dag-hallucination-detector, aris-research-pipeline

## Manual Steps

Some components require manual installation:

| Component | How to install |
|-----------|---------------|
| **OpenCode** | https://opencode.ai |
| **Wolfram Engine** | `brew install --cask wolfram-engine` then `wolframscript` to activate license |
| **ParaView** | https://www.paraview.org/download/ |
| **MacTeX** | `brew install --cask mactex` (for LaTeX/pdflatex) |
| **gh CLI** | `brew install gh` (for GitHub repo management) |
| **Firecrawl auth** | `firecrawl login --browser` (optional, works without on free tier) |

> **Note:** Playwright Chromium and Puppeteer Chrome are installed automatically by `setup.sh` (and kept in sync by `update-all.sh`) for render-visual and tldraw export. The Chrome version is auto-detected from the pinned tldraw-cli — no hardcoded version. If install fails, detect and install manually:
> ```bash
> VER=$(bash ~/stack/chrome-version.sh)   # detect version needed by tldraw
> npx playwright install chromium
> npx puppeteer browsers install "chrome@$VER"
> ```

## Project Structure

```
~/stack/
├── README.md                    # This file
├── AGENTS.md                    # AI agent instructions
├── STACK.md                     # Full documentation
├── workflow.txt                 # Git workflow rules
├── setup.sh                     # Installation script
├── check-all.sh                 # Verify all tools work
├── update-all.sh                # Update everything
├── new-project.sh               # Create/register project
├── sync-agents.sh               # Sync AGENTS.md to registered projects
├── sync-aris.sh                 # Sync ARIS skills from aris-skills.txt
├── chrome-version.sh            # Detect Chrome version pinned by tldraw-cli
├── check-wolfram-license.sh     # Check Wolfram license expiry
├── projects.txt                 # Project registry (one path per line)
├── aris-skills.txt              # ARIS skill list (single source of truth)
├── .gitignore
├── skills/                      # 8 standalone skills
│   ├── aris-research-pipeline/
│   ├── dag-hallucination-detector/
│   ├── data-analysis/
│   ├── deep-mind/
│   ├── epistemic-rigor/
│   ├── grill-me/
│   ├── render-visual/
│   └── xlsx/
└── WolframLanguage/             # User Wolfram packages
```

After installation, external repos are cloned into `~/stack/`:

```
├── paraview-mcp/                # ParaView MCP server
├── manim-mcp/                   # Manim MCP server
├── julia-mcp/                   # Julia MCP server
├── tldraw-mcp/                  # tldraw MCP server
├── aris-research-repo/          # ARIS research pipeline
└── WolframLanguageForJupyter/   # Jupyter kernel for Wolfram
```

## Usage

### Create New Project

```bash
~/stack/new-project.sh ~/projects/my-project    # create new
~/stack/new-project.sh ~/work/analysis          # anywhere
~/stack/new-project.sh ~/learn                  # register existing
```

Creates folder (if needed), copies `AGENTS.md`, registers in `projects.txt`.

### Sync AGENTS.md to All Projects

```bash
bash ~/stack/sync-agents.sh
```

Reads `projects.txt`, replaces stack section between `STACK:START`/`STACK:END` markers in each project's `AGENTS.md`. Project-specific content outside markers is preserved.

### Start OpenCode

```bash
cd ~/stack && opencode
```

### Aliases

| Alias | Command |
|-------|---------|
| `stack` | `cd ~/stack` |
| `manim-activate` | Activate Manim venv |
| `jupyter-jlab` | Start JupyterLab |
| `jupyter-wolfram` | Start Jupyter with Wolfram kernel |
| `new-project` | Create new project with AGENTS.md |

### Update Everything

```bash
cd ~/stack && bash update-all.sh
```

Updates all components in one command:
- Homebrew packages (node, python, gh, ffmpeg, etc.)
- External MCP repos (paraview-mcp, manim-mcp, julia-mcp, tldraw-mcp, etc.)
- tldraw-mcp build
- Python venvs (manim, jupyter, paraview-mcp, julia-mcp)
- npm global CLIs (firecrawl-cli, tldraw CLI)
- ARIS skills + standalone skills
- Julia packages
- Wolfram paclets
- AGENTS.md sync (all projects)

> **After updating, restart OpenCode** for MCP servers and skills to pick up changes.

### Check Everything Works

```bash
bash ~/stack/check-all.sh
```

## Workflow

See `workflow.txt` for the git workflow: branch → commit → PR → merge.

## Documentation

- `AGENTS.md` — AI agent instructions (MCP tools, conventions)
- `STACK.md` — Full documentation with hotkeys, examples, links
- `workflow.txt` — Git workflow rules
