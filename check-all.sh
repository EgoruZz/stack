#!/bin/bash
# Проверка что весь стэк работает
# Запуск: cd ~/stack && bash check-all.sh

export PATH="$HOME/.juliaup/bin:$PATH"

echo "=== Проверка стека ==="
echo ""

# Wolfram
echo -n "Wolfram: "
if command -v wolframscript &>/dev/null && wolframscript -version >/dev/null 2>&1; then
    echo "✅ $(wolframscript -version 2>/dev/null)"
else
    echo "❌ не найден"
fi

# ParaView
echo -n "ParaView: "
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)
if [ -n "$PVAPP" ] && [ -x "$PVAPP/Contents/bin/pvpython" ]; then
    echo "✅ $("$PVAPP/Contents/bin/pvpython" --version 2>/dev/null)"
else
    echo "❌ не найден"
fi

# Julia
echo -n "Julia: "
if command -v julia &>/dev/null; then
    echo "✅ $(julia --version 2>/dev/null)"
else
    echo "❌ не найден"
fi

# LaTeX
echo -n "LaTeX: "
if command -v pdflatex &>/dev/null; then
    echo "✅ $(pdflatex --version 2>/dev/null | head -1)"
else
    echo "❌ не найден"
fi

# Manim
echo -n "Manim: "
if [ -f ~/stack/manim-env/bin/activate ]; then
    source ~/stack/manim-env/bin/activate 2>/dev/null
    if python3 -c "import manim" >/dev/null 2>&1; then
        MANIM_VER=$(python3 -c "import manim; print(manim.__version__)" 2>/dev/null)
        echo "✅ v$MANIM_VER"
    else
        echo "❌ ошибка импорта"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv не найден"
fi

# ManimGL
echo -n "ManimGL: "
if [ -f ~/stack/manim-env/bin/activate ]; then
    source ~/stack/manim-env/bin/activate 2>/dev/null
    if python3 -c "import manimlib" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ ошибка импорта"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv не найден"
fi

# Jupyter
echo -n "Jupyter: "
if [ -f ~/stack/jupyter-env/bin/activate ]; then
    source ~/stack/jupyter-env/bin/activate 2>/dev/null
    if jupyter --version >/dev/null 2>&1; then
        echo "✅ $(jupyter --version 2>/dev/null | head -1)"
    else
        echo "❌ ошибка"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv не найден"
fi

# VS Code
echo -n "VS Code: "
if [ -d "/Applications/Visual Studio Code.app" ]; then
    VS_VER=$("/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --version 2>/dev/null | head -1)
    if [ -n "$VS_VER" ]; then
        echo "✅ $VS_VER"
    else
        echo "✅ установлен"
    fi
else
    echo "❌ не найден"
fi

# VS Code расширения стека
echo -n "VS Code ext: "
if command -v code >/dev/null 2>&1; then
    VS_EXTS=$(code --list-extensions 2>/dev/null)
    MISSING_EXT=""
    for ext in tldraw-org.tldraw-vscode ms-python.python ms-toolsai.jupyter \
               julialang.language-julia wolframresearch.wolfram james-yu.latex-workshop; do
        echo "$VS_EXTS" | grep -qix "$ext" || MISSING_EXT="$MISSING_EXT $ext"
    done
    if [ -z "$MISSING_EXT" ]; then
        echo "✅ 6/6"
    else
        echo "⚠️ не хватает:$MISSING_EXT"
    fi
else
    echo "❌ code CLI не найден"
fi

# OpenCode
echo -n "OpenCode: "
if command -v opencode >/dev/null 2>&1; then
    echo "✅ $(which opencode)"
else
    echo "❌ не найден"
fi

# Firecrawl
echo -n "Firecrawl: "
if command -v firecrawl >/dev/null 2>&1; then
    echo "✅ $(firecrawl --version 2>/dev/null)"
else
    echo "❌ не найден"
fi

# tldraw CLI
echo -n "tldraw CLI: "
if command -v tldraw >/dev/null 2>&1; then
    echo "✅ $(tldraw --version 2>/dev/null)"
else
    echo "❌ не найден"
fi

# Хранилище скиллов
echo -n "Skills store: "
if [ -d ~/stack/skills-store ]; then
    N=$(ls ~/stack/skills-store | wc -l | tr -d ' ')
    GLOBAL=$(ls ~/.config/opencode/skills 2>/dev/null | wc -l | tr -d ' ')
    if [ "$N" -ge 50 ] && [ "$GLOBAL" -eq 0 ]; then
        echo "✅ $N скиллов (глобальные каталоги чисты)"
    elif [ "$N" -lt 50 ]; then
        echo "⚠️ только $N скиллов — запусти: bash ~/stack/consolidate-skills.sh"
    else
        echo "⚠️ в ~/.config/opencode/skills $GLOBAL скиллов — запусти: bash ~/stack/consolidate-skills.sh"
    fi
else
    echo "❌ ~/stack/skills-store не найден"
fi

echo ""
echo "=== Готово ==="
