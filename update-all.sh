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

# JupyterLab
echo ">>> JupyterLab..."
source ~/stack/jupyter-env/bin/activate
pip install --upgrade jupyterlab
deactivate
echo ""

# Julia
echo ">>> Julia..."
juliaup update
echo ""

# Wolfram
echo ">>> Wolfram..."
wolframscript -code 'PacletUpdate[]' 2>/dev/null
echo ""

echo "=== Готово! ==="
echo ""
echo "Проверка версий:"
echo "  Wolfram: $(wolframscript -version 2>/dev/null)"
echo "  ParaView: $($(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)/Contents/bin/pvpython --version 2>/dev/null || echo 'не найден')"
echo "  Julia: $(julia --version 2>/dev/null)"
echo "  LaTeX: $(pdflatex --version 2>/dev/null | head -1)"
echo "  ManimGL: $(source ~/stack/manim-env/bin/activate && python3 -c 'import manimlib; print("OK")' 2>/dev/null)"
echo "  Jupyter: $(source ~/stack/jupyter-env/bin/activate && jupyter --version 2>/dev/null | head -1)"
