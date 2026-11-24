# STACK.md — full tool reference

> Paths: the stack lives wherever you cloned it (`STACK_DIR`, e.g. `~/stack`). Below, `$STACK` means that folder. Personal data lives outside the repo (`~/.stack-secrets.sh`, chmod 600).

## 1. Wolfram Language / Engine

- Free developer license. CLI: `wolframscript -code '...'`. MCP server: `Wolfram` (computation via AgentTools). Jupyter kernel: `wolframlanguage15`.
- The agent: writes `.wl` files, runs wolframscript, calls the MCP. You: run `wolframscript` interactively, view notebooks in the Wolfram desktop apps.
- License: renews every ~40 days at https://www.wolfram.com/engine/. Check: `wolframscript -code 'Print[$LicenseExpirationDate]'`; expiry tracker: `bash $STACK/check-wolfram-license.sh`. License data lives in `~/Library/Wolfram*` and survives resets. Expired → renew on the site → `wolframscript -activate` (interactive; non-interactive if `~/.stack-wolfram.conf` has WOLFRAM_ID/PASS).
- Packages: `wolframscript -code 'PacletInstall["PackageName"]'`; custom packages in `$STACK/WolframLanguage/`. Docs: https://reference.wolfram.com/language/

## 2. Manim

- **Manim** (community) — primary, headless: `manim script.py SceneName` → `.mp4`/`.png` in `media/`. MCP server `manim` renders to file (temp dirs auto-clean after 1h; `cleanup_manim_temp_dir` for manual cleanup).
- **ManimGL** (3Blue1Brown) — separate interactive CLI: `manimgl script.py SceneName`; player keys: `←/→` seek, `s` frame, `w` picture, `q` quit. No MCP uses it.
- Env: `source $STACK/manim-env/bin/activate`. Update: `pip install --upgrade manim manimgl`.
- Code structure: a `Scene` class with `construct()`; `self.play(...)`, `self.wait(...)`. Links: https://docs.manim.community/ · https://github.com/3b1b/manim

## 3. ParaView

- GUI + pvpython. Auto-detect: `PVAPP=$(ls -d /Applications/ParaView-*.app | head -1)`. Python API: `paraview.simple`.
- **MCP startup workflow (required):**
  ```bash
  PVAPP=$(ls -d /Applications/ParaView-*.app | head -1)
  open "$PVAPP"                                                    # 1. GUI
  nohup "$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111 &   # 2. pvserver
  # 3. GUI: File → Connect → localhost:11111
  "$PVAPP/Contents/bin/pvpython" $STACK/paraview-mcp/paraview_bridge.py       # 4. TCP bridge
  ```
  Shutdown: close the GUI; `kill $(pgrep -f pvserver) $(pgrep -f paraview_bridge)`.
- Screenshots: MCP screenshots are NOT available (bridge runs in a separate pvprocess). Press `P` in the GUI to save into `$STACK/paraview-mcp/screenshots/` and give the agent the path.
- MCP tools: load_data, create_source, create_isosurface, create_slice, toggle_volume_rendering, color_by, rotate_camera, reset_camera, plot_over_line, warp_by_vector, create_streamline, get_pipeline.
- Env: `$STACK/paraview-mcp-env`. Update: `brew upgrade --cask paraview` + `pip install -U` in that env. Docs: https://docs.paraview.org/

## 4. Julia

- CLI: `julia` (via juliaup). MCP server: `julia` (persistent REPL sessions).
- 20 preinstalled packages: LinearAlgebra, SparseArrays, Plots, DifferentialEquations, StaticArrays, Optim, JuMP, IJulia, Flux, Turing, DataFrames, CSV, ForwardDiff, SymPy, SpecialFunctions, StatsBase, Distributions, Polynomials, FFTW, IterativeSolvers.
- `using Pkg; Pkg.add("Name")` · `Pkg.status()` · `Pkg.update()`. REPL keys: `]` pkg mode, `?` help, `Ctrl+D` exit. Docs: https://docs.julialang.org/

## 5. JupyterLab

- Run: `source $STACK/jupyter-env/bin/activate && jupyter-lab` (stop: Ctrl+C). Kernels: Python 3.12 + Wolfram Language 15.
- Packages: numpy, matplotlib, pandas, sympy, plotly, ipywidgets, openpyxl, markitdown.
- Keys: `Shift+Enter` run, `A/B` cell above/below, `DD` delete, `M/Y` markdown/code, `Shift+M` merge.
- The agent writes `.ipynb`; you open and run; or the agent executes cells via MCP. Update: `pip install --upgrade jupyterlab`. Docs: https://jupyterlab.readthedocs.io/

## 6. LaTeX (MacTeX)

- `pdflatex document.tex` · bibliography: `pdflatex → bibtex → pdflatex ×2` or `latexmk document.tex`.
- VS Code LaTeX Workshop: `Cmd+L Cmd+C` compile, `Cmd+L Cmd+V` preview.
- Update: `brew upgrade --cask mactex`. Links: https://www.latex-project.org/help/documentation/ · https://en.wikibooks.org/wiki/LaTeX

## 7. VS Code

Extensions installed: Jupyter, Python, Julia, LaTeX Workshop, Wolfram Language. Config: `~/Library/Application Support/Code/User/settings.json`.
Keys: `Cmd+P` file, `Cmd+Shift+P` command, `` Cmd+` `` terminal, `Cmd+Shift+F` search, `Ctrl+G` line, `Alt+↑/↓` move line, `Cmd+/` comment.

## 8. OpenCode + MCP servers (10)

| Server | Function |
|:---:|:---:|
| Wolfram | Wolfram Language computation (AgentTools) |
| julia | Persistent Julia sessions |
| manim | Headless animation rendering |
| ParaView | 3D visualization (TCP bridge, workflow above) |
| tldraw | Whiteboard canvas, 30+ tools |
| wordcraft · gridcraft · deckcraft · pdfcraft · figcraft | Office documents via Craft Apps |

- Config lives in each project's `.opencode/opencode.json` (generated by `gen-opencode-config.sh` with absolute paths); global config stays clean.
- tldraw MCP works with an in-memory document and `.tldr` files — it is NOT a live controller of an already-open desktop canvas. PNG/SVG export via `@kitschpatrol/tldraw-cli` — verify schema compatibility after CLI updates.
- Manim MCP renders headless (community `manim`); ManimGL is not used by it.
- Code diagnostics: run compilers/linters directly (`bash -n`, `python`, `npm run build`, `julia`, `pdflatex`).
- Skills: 60 in `$STACK/skills-store` — render-visual, data-analysis, craft-office, grill-me, deep-mind, epistemic-rigor, dag-hallucination-detector, aris-research-pipeline, firecrawl-*, tldraw-offline. Research pipeline is local-only (local subagents, not independent cross-model review).
- render-visual Chromium check: `node $STACK/skills-store/render-visual/scripts/doctor.mjs` (with CHROME_PATH from Playwright cache).

## 8b. Craft Apps — office documents (ArtCraft)

Native open-source Rust apps: [getartcraft.com](https://getartcraft.com). GUI: `bash $STACK/craft-install.sh`. Headless CLI: `$STACK/craft-cli/<name>-cli`.

| App | Format | CLI | MCP |
|:---:|:---:|:---:|:---:|
| WordCraft | .docx (+.odt/.rtf/.html/.md/.tex, PDF export, APA/MLA/Chicago/IEEE citations, Zotero) | wordcraft-cli | wordcraft |
| GridCraft | .xlsx (+.csv; PivotTables, 500+ functions, charts) | gridcraft-cli | gridcraft |
| DeckCraft | .pptx (+.potx; PDF/PNG/GIF export) | deckcraft-cli | deckcraft |
| PdfCraft | .pdf (merge/split/protect/comments) | pdfcraft-cli | pdfcraft |
| FigCraft | UI/prototypes (.figcraft; PNG/SVG export) | figcraft-cli | figcraft |

```bash
$STACK/craft-cli/wordcraft-cli convert report.docx report.pdf
$STACK/craft-cli/wordcraft-cli inspect report.docx     # structure as JSON
$STACK/craft-cli/wordcraft-cli commands --json         # all app commands
# Live mode (agent edits a document in an open window):
/Applications/WordCraft.app/Contents/MacOS/wordcraft --control 7981
# ports: wordcraft 7981 · gridcraft 7982 · deckcraft 7983 · pdfcraft 7984 · figcraft 7985
```

The apps are pre-release: complex MS Office files open best-effort — keep backups. Final office deliverables go through Craft Apps, not python scripts. `.tex` compilation stays pdflatex. Detailed agent workflow: the `craft-office` skill.

## Network (proxy.sh)

ISP proxy (proxy.market) is set in `.zshrc` (STACK_PROXY_*); local stack traffic (all MCP, localhost) goes direct (no_proxy).

```bash
bash $STACK/proxy.sh status    # routes state
bash $STACK/proxy.sh git on    # git → github via proxy (off = direct)
bash $STACK/proxy.sh test      # live test + external IP
bash $STACK/proxy.sh expiry    # subscription expiry
```

If the network is down from the terminal — VPN client (fake-IP) or a dead proxy: run `proxy.sh test` first, then check the VPN.

## First-start data checklist (agent-driven)

After `setup.sh` the stack needs **personal** data — deliberately never in the repo. The AI agent leads this (see AGENTS.md "FIRST START"): it asks for the proxy line (`host:port:login:password`), git identity, optional Wolfram ID, writes `$STACK/first-start.txt`, runs `apply-first-start.sh`, verifies `proxy.sh test`. What only the user can do: sudo password prompts, browser logins (gh device, Firecrawl, Wolfram sign-in), and model-provider auth in OpenCode itself.

## Common commands

```bash
cd $STACK && bash update-all.sh   # update everything (15 steps, see below)
cd $STACK && bash check-all.sh    # health check — everything must be ✅
```

`update-all.sh` covers: Homebrew packages + cleanup · Apple CLT/system updates (sudo) · external MCP repos · tldraw-mcp build · Python venvs (manim/jupyter/paraview/julia) · npm global CLIs + Chrome for tldraw · VS Code extensions · skills (ARIS + standalone) · Julia packages · Wolfram paclets · Craft Apps versions + headless CLIs · projects sync · expiry report (proxy, Wolfram).

## Change rules (short)

1. **Check**: `bash -n <script>.sh` + `bash $STACK/check-all.sh` (the agent does this automatically)
2. **Idempotency**: re-running any script must be safe — always
3. **Secrets**: never in the repo — templates only; personal data in `~/.stack-secrets.sh` / `.zshrc` (chmod 600)
4. **Path-agnostic**: scripts self-locate their root; no hardcoded `$HOME/stack` in code; project configs get absolute paths; `AGENTS.template.md` (with `{{STACK}}`) is the source, `AGENTS.md` is a generated local render
5. **Consistent docs**: CLI/MCP/skills/step counters match across README, AGENTS.template.md, STACK.md
6. **One PR = one logical change** (workflow.txt)
