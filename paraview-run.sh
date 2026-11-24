#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# ParaView MCP launcher. Used as the MCP command in opencode.json:
#   ["bash", "<stack>/paraview-run.sh"]
# Why a wrapper (incompatibilities between the ParaView app python
# and a venv, found on a fresh machine):
#   - the MCP server needs the `paraview` module → PYTHONPATH points
#     into the ParaView app
#   - the app's compiled modules need libz from the bundle → DYLD_LIBRARY_PATH
#   - pvpython's own python has no `_ssl` → server runs on the venv python
#   - without a running pvserver the server dies after a 60s retry and
#     OpenCode shows "failing" → start headless pvserver automatically
# ═══════════════════════════════════════════════════════════════
set -uo pipefail

STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PVAPP="$(ls -d /Applications/ParaView-*.app 2>/dev/null | head -1)"
if [ -z "$PVAPP" ]; then
    echo "ParaView app not found in /Applications" >&2
    exit 1
fi

export PYTHONPATH="$PVAPP/Contents/Python:$PVAPP/Contents/Libraries/lib/python3.12:$STACK_DIR/paraview-mcp-env/lib/python3.12/site-packages"
export DYLD_LIBRARY_PATH="$PVAPP/Contents/Libraries:$PVAPP/Contents/Frameworks"

# Auto-start headless pvserver if nothing is LISTENING on 11111.
# NOTE: probe with lsof, NOT with `nc -z` — any raw connection to pvserver
# triggers its handshake, fails it, and pvserver exits.
if ! lsof -nP -iTCP:11111 -sTCP:LISTEN >/dev/null 2>&1; then
    ( "$PVAPP/Contents/bin/pvserver" --multi-clients --server-port=11111 \
        > "$STACK_DIR/paraview-mcp/pvserver.log" 2>&1 & )
    # wait until the port is listening (up to ~30 s)
    for _ in $(seq 1 30); do
        if lsof -nP -iTCP:11111 -sTCP:LISTEN >/dev/null 2>&1; then break; fi
        sleep 1
    done
fi

exec "$STACK_DIR/paraview-mcp-env/bin/python" "$STACK_DIR/paraview-mcp/paraview_mcp_server.py"
