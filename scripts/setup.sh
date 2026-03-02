#!/usr/bin/env bash
# Dex Setup — two paths to connect your AI client with Dex CRM:
#   1. If Go is available: generate a CLI binary via CLIHub (lightweight, no server needed)
#   2. If Go is not available: configure the hosted MCP server via add-mcp
set -euo pipefail

DEX_DIR="$HOME/.dex/bin"
MCP_URL="https://mcp.getdex.com/mcp"

# --------------------------------------------------------------------------
# Path 1: CLI generation (requires Go)
# --------------------------------------------------------------------------
setup_cli() {
  local os arch ext
  os=$(uname -s | tr '[:upper:]' '[:lower:]')
  arch=$(uname -m)
  case "$arch" in
    x86_64)  arch="amd64" ;;
    aarch64) arch="arm64" ;;
  esac
  ext=""
  case "$os" in
    mingw*|msys*|cygwin*) os="windows"; ext=".exe" ;;
  esac

  local dex_bin="$DEX_DIR/dex${ext}"

  if [ -x "$dex_bin" ]; then
    echo "dex CLI already installed at $dex_bin"
    "$dex_bin" auth status 2>/dev/null || echo "Run '$dex_bin auth' to authenticate."
    exit 0
  fi

  echo "Go found: $(go version)"

  local gopath clihub
  gopath=$(go env GOPATH)
  clihub="$gopath/bin/clihub"
  if [ ! -x "$clihub" ]; then
    echo "Installing clihub..."
    go install github.com/thellimist/clihub@latest
  fi
  echo "clihub found: $clihub"

  mkdir -p "$DEX_DIR"
  echo "Generating dex CLI for ${os}/${arch}..."
  "$clihub" generate \
    --url "$MCP_URL" \
    --oauth \
    --name dex \
    --platform "${os}/${arch}" \
    --output "$DEX_DIR"

  local platform_bin="$DEX_DIR/dex-${os}-${arch}${ext}"
  if [ -f "$platform_bin" ] && [ ! -f "$dex_bin" ]; then
    mv "$platform_bin" "$dex_bin"
  fi
  chmod +x "$dex_bin"

  echo ""
  echo "OK: dex CLI installed at $dex_bin"
  echo "Run '$dex_bin auth' to authenticate if needed."
}

# --------------------------------------------------------------------------
# Path 2: Configure MCP server across all detected clients via add-mcp
# Supports: Claude Code, Claude Desktop, Cursor, VS Code, Gemini CLI,
#           Codex, Goose, OpenCode, Zed, and more.
# --------------------------------------------------------------------------
setup_mcp() {
  echo "Go not found — configuring Dex MCP server connection instead."
  echo ""

  # add-mcp requires Node.js / npx
  if ! command -v npx &>/dev/null; then
    echo "ERROR: Neither Go nor Node.js found."
    echo ""
    echo "Install one of the following:"
    echo "  - Go (https://go.dev/dl/) — to generate a standalone Dex CLI"
    echo "  - Node.js (https://nodejs.org/) — to configure the MCP server in your editors"
    echo ""
    echo "Or add the Dex MCP server manually to your client's config:"
    echo ""
    print_mcp_snippet
    exit 1
  fi

  echo "Configuring Dex MCP server across all detected clients..."
  npx -y add-mcp "$MCP_URL" -y

  echo ""
  echo "OK: Dex MCP server configured. Restart your client(s) to connect."
  echo "You'll be prompted to authenticate via browser on first use."
}

print_mcp_snippet() {
  cat <<SNIPPET
{
  "mcpServers": {
    "dex": {
      "type": "http",
      "url": "$MCP_URL"
    }
  }
}
SNIPPET
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------
if command -v go &>/dev/null; then
  setup_cli
else
  setup_mcp
fi
