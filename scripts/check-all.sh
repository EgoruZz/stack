#!/bin/bash
# Check that the whole stack works
# Run: cd $STACK_DIR && bash check-all.sh

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export PATH="$HOME/.juliaup/bin:$PATH"

echo "=== Stack check ==="
echo ""

# Wolfram
echo -n "Wolfram: "
if command -v wolframscript &>/dev/null && wolframscript -version >/dev/null 2>&1; then
    echo "✅ $(wolframscript -version 2>/dev/null)"
else
    echo "❌ not found"
fi

# ParaView
echo -n "ParaView: "
PVAPP=$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)
if [ -n "$PVAPP" ] && [ -x "$PVAPP/Contents/bin/pvpython" ]; then
    PV_VER=$("$PVAPP/Contents/bin/pvpython" --version 2>/dev/null)
    if [ -n "$PV_VER" ]; then
        echo "✅ $PV_VER"
    else
        # pvpython may not support --version — the mere presence of the binary is enough
        echo "✅ $(basename "$PVAPP")"
    fi
else
    echo "❌ not found"
fi

# Julia
echo -n "Julia: "
if command -v julia &>/dev/null; then
    echo "✅ $(julia --version 2>/dev/null)"
else
    echo "❌ not found"
fi

# LaTeX
echo -n "LaTeX: "
if command -v pdflatex &>/dev/null; then
    echo "✅ $(pdflatex --version 2>/dev/null | head -1)"
else
    echo "❌ not found"
fi

# Manim
echo -n "Manim: "
if [ -f $STACK_DIR/manim-env/bin/activate ]; then
    source $STACK_DIR/manim-env/bin/activate 2>/dev/null
    if python3 -c "import manim" >/dev/null 2>&1; then
        MANIM_VER=$(python3 -c "import manim; print(manim.__version__)" 2>/dev/null)
        echo "✅ v$MANIM_VER"
    else
        echo "❌ import error"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv not found"
fi

# ManimGL
echo -n "ManimGL: "
if [ -f $STACK_DIR/manim-env/bin/activate ]; then
    source $STACK_DIR/manim-env/bin/activate 2>/dev/null
    if python3 -c "import manimlib" >/dev/null 2>&1; then
        echo "✅ OK"
    else
        echo "❌ import error"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv not found"
fi

# Jupyter
echo -n "Jupyter: "
if [ -f $STACK_DIR/jupyter-env/bin/activate ]; then
    source $STACK_DIR/jupyter-env/bin/activate 2>/dev/null
    if jupyter --version >/dev/null 2>&1; then
        echo "✅ $(jupyter --version 2>/dev/null | head -1)"
    else
        echo "❌ error"
    fi
    deactivate 2>/dev/null
else
    echo "❌ venv not found"
fi

# VS Code
echo -n "VS Code: "
if [ -d "/Applications/Visual Studio Code.app" ]; then
    VS_VER=$("/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" --version 2>/dev/null | head -1)
    if [ -n "$VS_VER" ]; then
        echo "✅ $VS_VER"
    else
        echo "✅ installed"
    fi
else
    echo "❌ not found"
fi

# Stack VS Code extensions
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
        echo "⚠️ missing:$MISSING_EXT"
    fi
else
    echo "❌ code CLI not found"
fi

# OpenCode
echo -n "OpenCode: "
if command -v opencode >/dev/null 2>&1; then
    echo "✅ $(which opencode)"
else
    echo "❌ not found"
fi

# Firecrawl
echo -n "Firecrawl: "
if command -v firecrawl >/dev/null 2>&1; then
    echo "✅ $(firecrawl --version 2>/dev/null)"
else
    echo "❌ not found"
fi

# tldraw CLI
echo -n "tldraw CLI: "
if command -v tldraw >/dev/null 2>&1; then
    echo "✅ $(tldraw --version 2>/dev/null)"
else
    echo "❌ not found"
fi

# Craft Apps (ArtCraft office suite)
echo -n "Craft Apps: "
CRAFT_OK=0; CRAFT_ALL=5
for app in WordCraft GridCraft DeckCraft PdfCraft FigCraft; do
    if [ -d "/Applications/$app.app" ]; then CRAFT_OK=$((CRAFT_OK+1)); fi
done
CLI_OK=0
for cli in wordcraft-cli gridcraft-cli deckcraft-cli pdfcraft-cli figcraft-cli; do
    [ -x $STACK_DIR/craft-cli/$cli ] && CLI_OK=$((CLI_OK+1))
done
if [ "$CRAFT_OK" -eq "$CRAFT_ALL" ] && [ "$CLI_OK" -eq "$CRAFT_ALL" ]; then
    echo "✅ 5/5 apps, 5/5 CLI"
else
    echo "⚠️ apps $CRAFT_OK/5, CLI $CLI_OK/5 — GUI: bash $STACK_DIR/scripts/craft-install.sh, CLI already at $STACK_DIR/craft-cli/"
fi

# Skills store
echo -n "Skills store: "
if [ -d $STACK_DIR/skills-store ]; then
    N=$(ls $STACK_DIR/skills-store | wc -l | tr -d ' ')
    GLOBAL=$(ls ~/.config/opencode/skills 2>/dev/null | wc -l | tr -d ' ')
    if [ "$N" -ge 50 ] && [ "$GLOBAL" -eq 0 ]; then
        # tldraw-offline is installed by the tldraw Desktop app on its first
        # launch: on a fresh machine it is absent until then — not an error,
        # but the user should know the 60th skill will appear later.
        if [ ! -d $STACK_DIR/skills-store/tldraw-offline ]; then
            echo "✅ $N skills (global dirs clean; the 60th — tldraw-offline — will appear after the first tldraw Desktop launch, then bash $STACK_DIR/consolidate-skills.sh)"
        else
            echo "✅ $N skills (global dirs clean)"
        fi
    elif [ "$N" -lt 50 ]; then
        echo "⚠️ only $N skills — run: bash $STACK_DIR/consolidate-skills.sh"
    else
        echo "⚠️ $GLOBAL skills in ~/.config/opencode/skills — run: bash $STACK_DIR/consolidate-skills.sh"
    fi
else
    echo "❌ $STACK_DIR/skills-store not found"
fi

# MCP servers: the modules each server imports must be present and compatible.
# History: mcp 2.x (released 2025-11) renamed FastMCP → old servers break; the
# ParaView app's bundled python lacks _ssl and ships an old typing_extensions;
# the manim server needs the venv's bin on PATH. Catch all of this here.
echo -n "MCP (julia/manim/paraview): "
MCP_OK=0; MCP_TOTAL=0
for env in julia-mcp-env manim-env paraview-mcp-env; do
    MCP_TOTAL=$((MCP_TOTAL+1))
    if [ -d "$STACK_DIR/$env" ] && "$STACK_DIR/$env/bin/python" -c "from mcp.server.fastmcp import FastMCP" >/dev/null 2>&1; then
        MCP_OK=$((MCP_OK+1))
    fi
done
PV_PATCHED=0
[ -f "$STACK_DIR/paraview-mcp/paraview_mcp_server.py" ] \
    && grep -q 'instructions=default_prompt' "$STACK_DIR/paraview-mcp/paraview_mcp_server.py" \
    && [ -f "$STACK_DIR/paraview-mcp/typing_extensions.py" ] && PV_PATCHED=1
if [ "$MCP_OK" -eq "$MCP_TOTAL" ] && [ "$PV_PATCHED" -eq 1 ]; then
    echo "✅ FastMCP importable in $MCP_OK/$MCP_TOTAL venvs; ParaView patched"
else
    echo "❌ FastMCP $MCP_OK/$MCP_TOTAL venvs; ParaView patches: $PV_PATCHED/1 — re-run: bash $STACK_DIR/scripts/setup.sh"
fi

# Attached projects: every registered project must exist, and its generated
# OpenCode config must point to THIS stack (otherwise — stack moved/re-cloned,
# or the project was detached and the registry entry is stale).
echo -n "Attached projects: "
PROJ_OK=0; PROJ_TOTAL=0; PROJ_STALE=0
if [ -f "$STACK_DIR/projects.txt" ]; then
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "${line// }" ]] && continue
        case "$line" in
            "~") P="$HOME" ;;
            "~/"*) P="$HOME/${line#\~/}" ;;
            *) P="$line" ;;
        esac
        PROJ_TOTAL=$((PROJ_TOTAL+1))
        if [ ! -d "$P" ]; then
            echo ""
            echo "  ⚠️ $line: folder gone — clean the registry: bash $STACK_DIR/scripts/sync-agents.sh --prune"
            PROJ_STALE=$((PROJ_STALE+1))
        elif [ -f "$P/.opencode/opencode.json" ] && grep -qF "$STACK_DIR" "$P/.opencode/opencode.json"; then
            PROJ_OK=$((PROJ_OK+1))
        else
            echo ""
            echo "  ⚠️ $P: config missing or points to another stack location — re-attach: bash $STACK_DIR/scripts/new-project.sh $P"
            PROJ_STALE=$((PROJ_STALE+1))
        fi
    done < "$STACK_DIR/projects.txt"
fi
if [ "$PROJ_TOTAL" -eq 0 ]; then
    echo "none registered — attach one: bash $STACK_DIR/scripts/new-project.sh <path>"
elif [ "$PROJ_STALE" -eq 0 ]; then
    echo "✅ $PROJ_OK/$PROJ_TOTAL point to this stack"
else
    echo "❌ $PROJ_OK/$PROJ_TOTAL point to this stack — fix the ⚠️ rows above"
fi

echo ""
echo "=== Done ==="
