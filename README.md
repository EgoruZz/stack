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
| JupyterLab | pip | Interactive notebooks |
| Firecrawl CLI | npm | Web scraping and research (28 skills) |
| tldraw CLI | npm | Whiteboard diagram export |
| 5 MCP servers | git clone | Wolfram, Julia, Manim, ParaView, tldraw |
| 49 skills | npm + git + local | AI skills for OpenCode |

### MCP Servers

| Server | What it does |
|--------|-------------|
| **Wolfram** | Wolfram Language computation (via AgentTools) |
| **Julia** | Persistent Julia REPL sessions |
| **Manim** | Headless animation rendering |
| **ParaView** | 3D visualization pipeline (via TCP bridge) |
| **tldraw** | Whiteboard canvas with 30+ tools |

### Skills (49 total)

- **28 Firecrawl** — web research, scraping, SEO, lead gen, market research
- **14 ARIS** — research pipeline, paper writing, experiment planning
- **1 tldraw-skill** — whiteboard diagram generation
- **7 standalone** — render-visual, data-analysis, xlsx, deep-mind, epistemic-rigor, grill-me, dag-hallucination-detector

## Manual Steps

Some components require manual installation:

| Component | How to install |
|-----------|---------------|
| **OpenCode** | https://opencode.ai |
| **Wolfram Engine** | `brew install --cask wolfram-engine` then `wolframscript` to activate license |
| **ParaView** | https://www.paraview.org/download/ |
| **Firecrawl auth** | `firecrawl login --browser` (optional, works without on free tier) |

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
├── new-project.sh               # Create new project
├── check-wolfram-license.sh     # Check Wolfram license expiry
├── opencode-template.jsonc      # MCP config template
├── .gitignore
├── skills/                      # 7 standalone skills
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
bash ~/stack/update-all.sh
```

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
