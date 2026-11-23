 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#001f1f',
    base02 = '#002e2e',
    base03 = '#228479',
    base04 = '#b7c4c4',
    base05 = '#f1fdfc',
    base06 = '#f1fdfc',
    base07 = '#f1fdfc',
    base08 = '#ff5c78',
    base09 = '#ffd46a',
    base0A = '#bc7dff',
    base0B = '#39e6cf',
    base0C = '#ffda80',
    base0D = '#8ef1e4',
    base0E = '#bd80ff',
    base0F = '#d8b3ff',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f1fdfc',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#228479',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#f1fdfc',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#228479',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#39e6cf',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#b7c4c4',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#39e6cf' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#bc7dff' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#ffd46a' })
  hi('TelescopeSelection',      { fg = '#f1fdfc',          bg = '#002e2e' })
  hi('TelescopeSelectionCaret', { fg = '#39e6cf',             bg = '#002e2e' })
  hi('TelescopeMatching',       { fg = '#39e6cf',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f1fdfc',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#228479',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#f1fdfc',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#39e6cf',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#39e6cf' })
  hi('MiniPickMatchCurrent',      { fg = '#f1fdfc',          bg = '#002e2e' })
  hi('MiniPickPromptCaret', { fg = '#39e6cf',             bg = '#002e2e' })
  hi('MiniPickMatchRanges',       { fg = '#39e6cf',             bold = true })
end

-- Register a signal handler for SIGUSR1 (matugen updates).
-- The handler re-requires this module, which re-runs the code below, so the
-- previous handle is stopped first; otherwise handlers double on every signal.
if _G.__matugen_signal then
  _G.__matugen_signal:stop()
  _G.__matugen_signal:close()
end

local signal = vim.uv.new_signal()
_G.__matugen_signal = signal
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    package.loaded['matugen'] = nil
    require('matugen').setup()
  end)
)

return M
