# AGENTS.md

<!-- STACK:START -->
## Installed stack

The stack lives in `{{STACK}}/`. Start OpenCode here: `cd {{STACK}} && opencode`.

## ⭐ FIRST START — agent-driven (do this when `~/.stack-secrets.sh` is missing)

If `~/.stack-secrets.sh` does not exist, the stack is not configured yet. **You lead the setup** — do not dump a manual on the user. Procedure:

1. Read the template `{{STACK}}/first-start.template.txt` to know the fields
2. Ask the user in chat for: ISP-proxy line (`host:port:login:password`, from proxy.market), subscription expiry, git name/email; optionally Wolfram ID + password (enables non-interactive license activation)
3. Create `{{STACK}}/first-start.txt` from the template, write in the values the user gave
4. Run `bash {{STACK}}/apply-first-start.sh` — it validates and writes `~/.stack-secrets.sh`
5. Verify: `bash {{STACK}}/proxy.sh test` — must report a live proxy and a working GitHub API
6. Craft Apps GUI: `bash {{STACK}}/craft-install.sh` (DMG installs; if macOS asks for the password, the user enters it in their terminal — you run the script and report)
7. Wolfram license: check `bash {{STACK}}/check-wolfram-license.sh`; if expired, guide renewal at https://www.wolfram.com/engine/, then try `wolframscript -activate` non-interactively with the WOLFRAM_ID/PASS from the form; if those are absent — the user signs in interactively in `wolframscript`
8. Firecrawl (optional): suggest `firecrawl login --browser` (user action, browser needed)
9. Projects: ask which folders should use the stack, then `bash {{STACK}}/new-project.sh <path>` for each (any folder, git not required)
10. Finish: `bash {{STACK}}/check-all.sh` — every row must be ✅ — and tell the user to restart OpenCode in each project folder

Interactive-by-design (only the user can do them): sudo password prompts, browser confirmations (gh device login, Firecrawl login, Wolfram sign-in). Everything else — you run and verify yourself. If the form already exists and is filled, skip the questions and go straight to `apply-first-start.sh`.

## Repository map ({{STACK}})

| File / folder | Purpose |
|:---:|:---:|
| `AGENTS.template.md` | Agent instructions source (a path placeholder is substituted on render); `AGENTS.md` is a local render, gitignored — edit the template only |
| `README.md` | Human documentation |
| `STACK.md` | Full tool reference (keybinds, examples) |
| `workflow.txt` | The owner's personal git flow |
| `setup.sh` | Clean-macOS install (12 steps, idempotent) |
| `update-all.sh` | Full update (15 steps) + expiry tracking |
| `check-all.sh` | Health check (✅/❌ per component) |
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
| `projects.txt` | Project registry (personal, gitignored) |
| `first-start.template.txt` | First-start form template |
| `aris-skills.txt` | 14 ARIS skills |
| `skills/` | 8 standalone skills (source) |
| `skills-store/` | Runtime store of 60 skills (gitignored, generated) |
| `craft-cli/`, `craft-downloads/` | Craft headless CLIs + DMG cache (gitignored) |
| `WolframLanguage/` | Custom Wolfram packages |
| `paraview-mcp/ · manim-mcp/ · julia-mcp/ · tldraw-mcp/ · aris-research-repo/ · WolframLanguageForJupyter/` | Cloned external repos (gitignored) |

## Tools

### Wolfram Language
- Free developer license; CLI: `wolframscript`; MCP server: `Wolfram`; Jupyter kernel: `wolframlanguage15`
- License renews every ~40 days at https://www.wolfram.com/engine/; license data lives in `~/Library/Wolfram*` and SURVIVES session resets and git pulls
- Activation creds: `~/.stack-wolfram.conf` (written by apply-first-start.sh); if absent — ask the user
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
- Screenshots: `{{STACK}}/paraview-mcp/screenshots/` (MCP screenshots are NOT available — the bridge runs in a separate pvprocess; ask the user to press P in the GUI, then read the file)
- **Startup workflow (required):** 1) `open "$PVAPP"` 2) `"$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111` 3) GUI: File → Connect → localhost:11111 4) `"$PVAPP/Contents/bin/pvpython" {{STACK}}/paraview-mcp/paraview_bridge.py` — the MCP connects automatically
- **Shutdown:** close the GUI; `kill $(pgrep -f pvserver)`; `kill $(pgrep -f paraview_bridge)`
- MCP tools: load_data, create_source, create_isosurface, create_slice, toggle_volume_rendering, color_by, rotate_camera, reset_camera, plot_over_line, warp_by_vector, create_streamline, get_pipeline, …

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
- GUI install/update: `bash {{STACK}}/craft-install.sh`; the skill `craft-office` holds the detailed workflow

### Jupyter
- Env: `{{STACK}}/jupyter-env`; run: `source {{STACK}}/jupyter-env/bin/activate && jupyter-lab`
- Kernels: Python 3.12 + Wolfram Language 15; packages: numpy, matplotlib, pandas, sympy, plotly, ipywidgets, openpyxl, markitdown

### VS Code
- Extensions: Jupyter, Python, Julia, LaTeX Workshop, Wolfram Language; config: `~/Library/Application Support/Code/User/settings.json`

## OpenCode specifics
- Project-scoped: MCP config lives in the project's `.opencode/opencode.json` (generated by gen-opencode-config.sh); outside attached projects the agent sees none of the stack
- **Version:** OpenCode **v2** (brew `anomalyco/tap/opencode-v2`, v1 removed). v2 casualties: no LSP servers (the `lsp` field is ignored), no `OPENCODE_DISABLE_*_SKILLS` variables; v1-form MCP configs are normalized automatically
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
cd {{STACK}} && bash check-all.sh     # everything must be ✅
cd {{STACK}} && bash update-all.sh
```
<!-- STACK:END -->
