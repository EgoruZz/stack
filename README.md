<p align="center">
  <img src="assets/banner.png" alt="Stack" width="100%">
</p>

<h1 align="center">Stack</h1>

<p align="center">
  A local OpenCode stack for a macOS machine: research, math, rendering and office tools — installed, wired into projects and driven by the AI agent.<br>
  <b><code>AGENTS.md</code> — instructions for the agent</b> · <b><code>STACK.md</code> — manual for the user</b>
</p>

---

## Why

One repo that turns a clean macOS into a full AI-driven workstation:

- **Wolfram Language, Julia, Python (Manim, Jupyter), ParaView, LaTeX** for science and math
- **Craft Apps** (Word / Excel / PowerPoint / PDF) for office documents
- **tldraw, render-visual, Firecrawl** for whiteboards, diagrams and web research
- **OpenCode** as the agent that runs it all — with per-project MCP configs, so nothing leaks globally
- **One mental model**: the agent leads setup, updates and health checks; you only answer questions and confirm in the browser

Everything is idempotent: run the same script on a fresh or an already-configured machine and it installs what is missing and updates what exists — never duplicating tools.

## Repository structure

| Path | What it is |
|:---|:---|
| `AGENTS.template.md` | Agent instructions source; rendered into `AGENTS.md` (gitignored) with the real stack path |
| `STACK.md` | Full tool reference for the user (keybinds, examples) |
| `scripts/` | All stack scripts — setup, update, check, teardown, proxy, project management |
| `skills/` | 8 standalone agent skills (source) |
| `first-start.template.txt` | Form the agent fills in with you during first start |
| `workflow.txt` | The owner's personal git flow |
| `assets/` | Banner and art |
| `aris-skills.txt`, `projects.template.txt` | Skill list and project registry template |

Everything else (`skills-store/`, `craft-cli/`, cloned MCP repos, venvs) is generated and gitignored.

## Quick start

Four steps. The rest the agent does with you, in chat.

**1. Install OpenCode**

```bash
brew install anomalyco/tap/opencode-v2
```

**2. Clone the stack**

```bash
git clone https://github.com/custom-opencode/stack.git ~/git/custom-opencode/stack
```

**3. Start OpenCode from the stack folder**

```bash
cd ~/git/custom-opencode/stack
opencode
```

**4. Write the first message in chat**

```
Set up the stack
```

That's it. The agent reads `AGENTS.md`, runs the installation, asks you for the personal data (proxy, git identity, Wolfram ID — each optional, and it warns what stops working if you decline), fills the form, verifies every component and attaches your project folders. When it finishes, every row of its health check is ✅ — restart OpenCode in your project folder and work.

You only ever do what only a human can do: type answers, click links, confirm in the browser.

## Destructor

```bash
bash scripts/teardown.sh [--deep] [--dry]
```

Removes everything the stack installed or changed:

- detaches the stack from all projects (project-scoped MCP configs and skills go with them — none of it is global)
- cleans files it wrote: `.zshrc` proxy block, `~/.stack-secrets.sh`, `~/.stack-wolfram.conf`, Firecrawl state
- removes generated artifacts: venvs, cloned MCP repos, `craft-cli`, skills-store
- with `--deep`: brew packages the stack added (identified against `.brew-pre-manifest.txt` — a snapshot of what existed before installation), npm CLIs, VS Code extensions

**Never touched:** OpenCode itself, the stack git repo, Wolfram license data, and anything the user had before installation.

Run with `--dry` first to audit every action without executing anything.
