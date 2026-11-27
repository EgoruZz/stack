<p align="left">
  🤖 <code>AGENTS.md</code> — instructions for the agent · 🙋‍♂️ <code>STACK.md</code> — manual for the user
</p>

---

## Constructor

**1. Install OpenCode**

Download it to your terminal however you like — see <a href="https://opencode.ai/terminal" target="_blank" rel="noopener">opencode.ai/terminal</a>

**2. Clone the stack anywhere**

```bash
git clone https://github.com/custom-opencode/stack.git <path>
```

**3. Start OpenCode from the stack folder**

```bash
cd <path>
opencode
```

**4. Write the first message in chat**

```
Set up the stack
```

**5. You only ever do what only a human can do: type answers, click links, confirm in the browser.**

## Destructor

```bash
bash scripts/teardown.sh [--deep] [--dry]
```

Removes everything the stack installed or changed:

- detaches the stack from all projects (project-scoped MCP configs and skills go with them — none of it is global)
- cleans files it wrote: `.zshrc` proxy block, `~/.stack-secrets.sh`, `~/.stack-wolfram.conf`, Firecrawl state
- removes generated artifacts: venvs, cloned MCP repos, `craft-cli`, skills-store
- with `--deep`: brew packages the stack added (identified against `.brew-pre-manifest.txt` — a snapshot of what existed before installation)
- every removal asks `y/N`: Craft Apps, VS Code extensions, npm CLIs, browser caches, brew packages, Julia depot, Firecrawl state, the Wolfram AgentTools paclet (or use `--yes` to answer `y` to everything)

**Never touched:** OpenCode itself, the stack git repo, Wolfram license data, and anything the user had before installation.

Run with `--dry` first to audit every action without executing anything.
