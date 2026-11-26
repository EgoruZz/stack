# AGENTS.md — Stack agent instructions

<!-- STACK:START -->
## Installed stack

The stack lives in `{{STACK}}`. Start OpenCode there (or in any project attached to it). All scripts are in `{{STACK}}/scripts/`.

## ⭐ FIRST START — agent-driven (do this when `~/.stack-secrets.sh` is missing)

If `~/.stack-secrets.sh` does not exist, the stack is not configured yet. **You lead the setup.** The user only does what only a human can do: type answers, confirm in the browser, enter passwords in prompts. Everything else you run and verify yourself.

### Golden rules

- Ask before you install nothing — setup.sh handles installation; you handle configuration.
- Every optional feature (proxy, git identity, Wolfram, Firecrawl, sudo) is a question with a consequence: if the user declines, tell them plainly what will not work. Declined = skipped, never half-configured.
- Never run `scripts/teardown.sh` while debugging — it is for full removal only. Never pipe canned answers into it.
- An existing filled `first-start.txt` or an existing `~/.stack-secrets.sh` means personal data is already known: do NOT delete or overwrite it. `scripts/apply-first-start.sh` is idempotent and safe to re-run; an EMPTY form is not.

### Procedure

0. **Install (fresh clone)**: if `scripts/setup.sh` has not run yet (quick check: no `craft-cli/` or no `.opencode/opencode.json` in the stack folder), run `bash {{STACK}}/scripts/setup.sh` — it installs everything (12 steps; brew steps take minutes; macOS may ask for the password in the terminal). When it finishes, tell the user to restart OpenCode so the generated config (MCP + skills) loads, then continue.
1. Read the template `{{STACK}}/first-start.template.txt` to know the fields.
2. Ask the user in chat, one block of questions at a time:
   - ISP-proxy line (`host:port:login:password`, from proxy.market) + subscription expiry — if declined: web access and git-via-proxy will not be routed through the proxy (direct connection is used; may fail where GitHub is blocked)
   - git name/email — if declined: commits and PRs from the agent will not be possible
   - Wolfram ID + password (optional) — if declined: license activation is interactive, the user signs in inside `wolframscript`
   - Firecrawl (optional) — if declined: web-scraping skills will not authenticate
3. Create `{{STACK}}/first-start.txt` from the template, write in the values the user gave (leave declined fields empty).
4. Run `bash {{STACK}}/scripts/apply-first-start.sh` — it validates and writes `~/.stack-secrets.sh`.
5. Verify: `bash {{STACK}}/scripts/proxy.sh test` — must report a live proxy and a working GitHub API.
6. Craft Apps GUI: `bash {{STACK}}/scripts/craft-install.sh` (DMG installs; if macOS asks for the password, the user enters it in their terminal — you run the script and report).
7. tldraw Desktop (GUI canvas, https://office.tldraw.com): check whether `/Applications/tldraw.app` exists; if not, tell the user to download and install it from the site (browser step), then the `tldraw` MCP and the `tldraw-offline` skill work with it.
8. Wolfram license: check `bash {{STACK}}/scripts/check-wolfram-license.sh`; if expired, try `wolframscript -activate` non-interactively with the WOLFRAM_ID/PASS from the form; if those are absent — the user signs in interactively in `wolframscript`.
9. Firecrawl (optional): ask the user for the API key (firecrawl.dev → dashboard) and run it yourself: `firecrawl login -k <key>`; if the user prefers not to paste the key, run `firecrawl login --browser` — the command runs in your terminal, the user only confirms in the browser. Verify with `firecrawl --status`.
10. Projects: ask which folders should use the stack, then `bash {{STACK}}/scripts/new-project.sh <path>` for each (any folder, git not required).
11. Finish: `bash {{STACK}}/scripts/check-all.sh` — every row must be ✅ — and tell the user to restart OpenCode in each project folder.

Interactive-by-design (only the user can do them): sudo password prompts, browser confirmations (gh device login, Firecrawl login, Wolfram sign-in). Everything else — you run and verify yourself.

## Repository map ({{STACK}})

| File / folder | Purpose |
|:---:|:---:|
| `AGENTS.template.md` | Agent instructions source (a path placeholder is substituted on render); `AGENTS.md` is a committed bootstrap for fresh clones, overwritten by a local render — edit the template only |
| `README.md` | Human documentation |
| `STACK.md` | Full tool reference (keybinds, examples) |
| `workflow.txt` | The owner's personal git flow |
| `scripts/` | All stack scripts (setup, update, check, teardown, projects, proxy, …) |
| `.brew-pre-manifest.txt` | Pre-install snapshot of brew packages — teardown `--deep` uses it to know what the user had before; never delete it |
| `first-start.template.txt` | First-start form template |
| `projects.txt` | Project registry (personal, gitignored) |
| `aris-skills.txt` | 14 ARIS skills |
| `skills/` | 8 standalone skills (source) |
| `skills-store/` | Runtime store of 60 skills (gitignored, generated) |
| `craft-cli/`, `craft-downloads/` | Craft headless CLIs + DMG cache (gitignored) |
| `WolframLanguage/` | Custom Wolfram packages |
| `paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ · aris-research-repo/ · WolframLanguageForJupyter/` | Cloned external repos (gitignored) |

## Scripts (in `scripts/`)

| Script | Purpose |
|:---:|:---:|
| `setup.sh` | Clean-macOS install (12 steps, idempotent) |
| `update-all.sh` | Full update (15 steps) + expiry tracking |
| `check-all.sh` | Health check (✅/❌ per component, incl. MCP modules) |
| `teardown.sh` | Uninstall everything the stack installed; keeps OpenCode itself |
| `new-project.sh` | Attach the stack to any folder (AGENTS.md + `.opencode/opencode.json`) |
| `detach-project.sh` | Detach (works even if the folder is already gone) |
| `export-personal.sh` | Collect personal files (registry, form, secrets) for backup/migration |
| `sync-agents.sh` | AGENTS.md + configs → all projects (`--prune` drops dead registry entries; rewrites paths if the stack moved) |
| `gen-opencode-config.sh` | Generates `.opencode/opencode.json` (10 MCP + skills) with absolute paths |
| `sync-aris.sh` | ARIS skills → skills-store (list: aris-skills.txt) |
| `consolidate-skills.sh` | Assemble skills-store + clean global skill dirs |
| `craft-install.sh` | Install/update Craft Apps GUI |
| `proxy.sh` | ISP-proxy routing (status / test / expiry / git on-off) |
| `chrome-version.sh` | Chrome version pinned by tldraw-cli |
| `check-wolfram-license.sh` | Wolfram license expiry |
| `apply-first-start.sh` | Validate the form → write `~/.stack-secrets.sh` |

## Tools

### Wolfram Language
- Free developer license; CLI: `wolframscript`; MCP server: `Wolfram`; Jupyter kernel: `wolframlanguage15`
- License renews every ~40 days at https://www.wolfram.com/engine/; license data lives in `~/Library/Wolfram*` and SURVIVES session resets and git pulls
- Activation creds: `~/.stack-wolfram.conf` (written by scripts/apply-first-start.sh); if absent — ask the user
- Expired: renew on the site → try `wolframscript -activate` (interactive unless WOLFRAM_ID/PASS exist in the form)
- Check: `wolframscript -code 'Print[$LicenseExpirationDate]'`
- Custom packages: `{{STACK}}/WolframLanguage/`; Jupyter integration: `{{STACK}}/WolframLanguageForJupyter/`

### Manim
- **Manim** (community) — the primary renderer, headless; **ManimGL** (3Blue1Brown) — separate interactive GUI CLI, no MCP
- Env: `{{STACK}}/manim-env` (Python 3.12); activate: `source {{STACK}}/manim-env/bin/activate`
- Run: `manim script.py SceneName` (GL: `manimgl script.py SceneName`); MCP server: `manim` (headless)

### ParaView
- Auto-detected: `PVAPP=$(ls -d /Applications/ParaView-*.app | head -1)`; pvpython: `$PVAPP/Contents/bin/pvpython`; API: `paraview.simple`
- MCP server: `ParaView`; env: `{{STACK}}/paraview-mcp-env`
- **The MCP config launches `bash {{STACK}}/scripts/paraview-run.sh`** — the wrapper sets PYTHONPATH/DYLD_LIBRARY_PATH (incompatibilities between the app python and a venv) and auto-starts a headless pvserver on :11111 if none is running. So the MCP works out of the box, no GUI needed.
- Screenshots with the GUI visible: open the GUI, File → Connect → localhost:11111, press P — then read `{{STACK}}/paraview-mcp/screenshots/`
- **Shutdown:** close the GUI; `kill $(pgrep -f pvserver)`

### LaTeX
- MacTeX: `pdflatex document.tex`; VS Code: LaTeX Workshop

### Julia
- Via juliaup; CLI: `julia`; MCP server: `julia`
- Packages: LinearAlgebra, SparseArrays, Plots, DifferentialEquations, StaticArrays, Optim, JuMP, IJulia, Flux, Turing, DataFrames, CSV, ForwardDiff, SymPy, SpecialFunctions, StatsBase, Distributions, Polynomials, FFTW, IterativeSolvers

### tldraw
- MCP server: `tldraw` (30+ tools; server: `{{STACK}}/tldraw-mcp/`, Node.js, zero browser deps)
- Tools: create_geo, create_text, create_arrow, create_note, create_frame, move_shapes, group_shapes, set_camera, save_document, load_document, …
- Export `.tldr` → PNG/SVG via `@kitschpatrol/tldraw-cli`; after CLI updates re-check MCP file schema compatibility
- The MCP reliably creates/saves/edits `.tldr`; live sync with an already-open desktop canvas is not guaranteed

### Craft Apps (office documents, ArtCraft)
- WordCraft / GridCraft / DeckCraft / PdfCraft / FigCraft — Word/Excel/PowerPoint/PDF/UI design, in /Applications (pre-release; keep backups of important documents)
- MCP servers: `wordcraft`, `gridcraft`, `deckcraft`, `pdfcraft`, `figcraft`; headless CLI: `{{STACK}}/craft-cli/<name>-cli` (convert, run, inspect, info, commands)
- **Final office deliverables (.docx/.xlsx/.pptx/.pdf) go through Craft Apps**, not python scripts
- `.tex` compilation is still pdflatex; WordCraft only imports/exports .tex
- Live mode (edits in an open window): `/Applications/<App>.app/Contents/MacOS/<app> --control 798X`; ports: wordcraft 7981, gridcraft 7982, deckcraft 7983, pdfcraft 7984, figcraft 7985
- GUI install/update: `bash {{STACK}}/scripts/craft-install.sh`; the skill `craft-office` holds the detailed workflow

### Jupyter
- Env: `{{STACK}}/jupyter-env`; run: `source {{STACK}}/jupyter-env/bin/activate && jupyter-lab`
- Kernels: Python 3.12 + Wolfram Language 15; packages: numpy, matplotlib, pandas, sympy, plotly, ipywidgets, openpyxl, markitdown

### VS Code
- Extensions: Jupyter, Python, Julia, LaTeX Workshop, Wolfram Language; config: `~/Library/Application Support/Code/User/settings.json`

## OpenCode specifics
- Project-scoped: MCP config lives in the project's `.opencode/opencode.json` (generated by scripts/gen-opencode-config.sh); outside attached projects the agent sees none of the stack — this is deliberate: nothing global leaks into other sessions
- **Version:** OpenCode **v2** (brew `anomalyco/tap/opencode-v2`, v1 removed). v2 casualties: no LSP servers (the `lsp` field is ignored), no `OPENCODE_DISABLE_*_SKILLS` variables; v1-form MCP configs are normalized automatically
- **Known MCP fixes (built into setup.sh / update-all.sh — do not "clean up"):**
  - `mcp[cli]<2` pinned in julia-mcp-env, manim-env, paraview-mcp-env — mcp 2.x (2025-11) renamed FastMCP and breaks the servers
  - ParaView server: run via venv python with `PYTHONPATH` (ParaView app's `Contents/Python` + `Libraries/lib/python3.12` + venv site-packages) and `DYLD_LIBRARY_PATH` (`Contents/Libraries` + `Contents/Frameworks`) — pvpython's bundled python has no `_ssl`; the server code is patched (`instructions=` instead of `system_prompt=`) and needs the fresh `typing_extensions.py` copied next to it
  - manim server needs `PATH` with `manim-env/bin` (set in the generated config)
  - ParaView MCP only fully works with `pvserver --multi-clients --server-port=11111` running (see the workflow above) — without it the server starts but tools fail to connect; that is expected, not a bug
- **Code diagnostics:** run linters/compilers/tests directly — `bash -n` (.sh), `python` (.py), `npm run build` (.ts), `julia` (.jl), `pdflatex` (.tex). Verify edits with a compiler before claiming success
- Skills: 60 in `{{STACK}}/skills-store` (Firecrawl 37, ARIS 14, standalone 8, tldraw-offline 1 — the last one appears after the first tldraw Desktop launch, then `consolidate-skills.sh`)
- ARIS runs local-only: external Codex/Oracle/manual-review MCPs are NOT available
- Multi-round verification uses local OpenCode subagents; never call it independent cross-model review
- For research claims, explicitly separate verified / inferred / unknown; a missing source is not confirmation

### Visualization routing
- `render-visual` — polished PNG/SVG/PDF, slides, architecture diagrams, GIF (headless Chromium)
- tldraw MCP — editable whiteboard `.tldr` documents
- Data charts from datasets → `data-analysis`/matplotlib/plotly, not schematic render-visual charts
- Ambiguous between tldraw and render-visual → clarify: editable canvas or final image?

## STACK.md — situational reference

Read `{{STACK}}/STACK.md` before the first work with a tool in a session (Wolfram, Manim, ParaView, tldraw, Julia, Jupyter), for keybinds/examples/links, and when visualization or update details are missing. Take only the needed tool section — do not read the whole file.

## Conventions
- All Python projects in venvs (PEP 668 protects the system Python)
- Julia via juliaup, packages in the global environment
- Wolfram: wolframscript for CLI, MCP for AI integration
- ParaView scripts in Python (`paraview.simple`)

## Package management
```bash
# Manim ({{STACK}}/manim-env)
source {{STACK}}/manim-env/bin/activate && pip install --upgrade manim manimgl
# Jupyter ({{STACK}}/jupyter-env)
source {{STACK}}/jupyter-env/bin/activate && pip install --upgrade jupyterlab
# Julia
julia -e 'using Pkg; Pkg.add("PackageName")'    # Pkg.update() to update all
# Wolfram
wolframscript -code 'PacletInstall["PackageName"]'
# Full check / update
bash {{STACK}}/scripts/check-all.sh     # everything must be ✅
bash {{STACK}}/scripts/update-all.sh
```
<!-- STACK:END -->
