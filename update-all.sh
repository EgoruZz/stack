#!/bin/bash
# Скрипт обновления всего стека
# Запуск: cd ~/stack && bash update-all.sh

echo "=== Обновление стека ==="
echo ""

# Homebrew
echo ">>> Homebrew..."
brew update && brew upgrade
echo ""

# Manim
echo ">>> Manim..."
source ~/stack/manim-env/bin/activate
pip install --upgrade manim manimgl
deactivate
echo ""

# JupyterLab + deps
echo ">>> JupyterLab..."
source ~/stack/jupyter-env/bin/activate
pip install --upgrade jupyterlab numpy matplotlib pandas sympy plotly ipywidgets openpyxl markitdown
deactivate
echo ""

# ParaView MCP deps
echo ">>> ParaView MCP..."
source ~/stack/paraview-mcp-env/bin/activate
pip install --upgrade -r ~/stack/paraview-mcp/requirements.txt
deactivate
echo ""

# Julia MCP deps
echo ">>> Julia MCP..."
source ~/stack/julia-mcp-env/bin/activate
pip install --upgrade "mcp[cli]"
deactivate
echo ""

# Julia packages
echo ">>> Julia..."
juliaup update
julia -e 'using Pkg; Pkg.update()' 2>/dev/null || echo "  Julia packages: обновление пропущено"
echo ""

# Wolfram
echo ">>> Wolfram..."
wolframscript -code 'PacletUpdate[]' 2>/dev/null
echo ""

# Firecrawl CLI
echo ">>> Firecrawl CLI..."
npm update -g firecrawl-cli 2>/dev/null || echo "  Firecrawl: обновление пропущено"
echo ""

# tldraw CLI
echo ">>> tldraw CLI..."
npm update -g @kitschpatrol/tldraw-cli 2>/dev/null || echo "  tldraw CLI: обновление пропущено"
echo ""

echo "=== Готово! ==="
echo ""
echo "Проверка версий:"
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)
echo "  Wolfram: $(wolframscript -version 2>/dev/null || echo 'не найден')"
echo "  ParaView: $("$PVAPP/Contents/bin/pvpython" --version 2>/dev/null || echo 'не найден')"
echo "  Julia: $(julia --version 2>/dev/null || echo 'не найден')"
echo "  LaTeX: $(pdflatex --version 2>/dev/null | head -1 || echo 'не найден')"
echo "  Manim: $(source ~/stack/manim-env/bin/activate && python3 -c 'import manim; print(manim.__version__)' 2>/dev/null || echo 'не найден')"
echo "  Jupyter: $(source ~/stack/jupyter-env/bin/activate && jupyter --version 2>/dev/null | head -1 || echo 'не найден')"
echo "  Firecrawl: $(firecrawl --version 2>/dev/null || echo 'не найден')"
echo "  tldraw CLI: $(tldraw --version 2>/dev/null || echo 'не найден')"
