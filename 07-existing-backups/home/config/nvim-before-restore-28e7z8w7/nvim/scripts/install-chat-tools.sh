#!/usr/bin/env bash
set -euo pipefail

# Keep bridge tools in the user's existing local bin directory.
export PATH="$HOME/.local/bin:$PATH"
for tool in npm nvim git; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing required tool: %s\n' "$tool" >&2
    exit 1
  fi
done

npm install --global --prefix "$HOME/.local" --no-audit --no-fund \
  @agentclientprotocol/codex-acp @agentclientprotocol/claude-agent-acp

nvim --headless \
  '+lua require("lazy").install({ plugins = { "codecompanion.nvim" }, wait = true, show = false })' \
  '+lua if not require("lazy.core.config").plugins["codecompanion.nvim"]._.installed then vim.cmd("cquit 1") end' \
  '+qa'

command -v codex-acp
command -v claude-agent-acp
printf '\nChat tools installed. Restart Neovim and press Space a a.\n'
printf 'Sign in through codex login or claude auth login if needed.\n'
