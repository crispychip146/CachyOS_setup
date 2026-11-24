 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#1d1e1f',
    base02 = '#262728',
    base03 = '#8a7d5e',
    base04 = '#c2c2c1',
    base05 = '#fffdf8',
    base06 = '#fffdf8',
    base07 = '#fffdf8',
    base08 = '#ff5c78',
    base09 = '#8ba9e4',
    base0A = '#f3e5ca',
    base0B = '#ffe09b',
    base0C = '#96b2e9',
    base0D = '#ffd780',
    base0E = '#e9cc96',
    base0F = '#f4e1be',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#fffdf8',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8a7d5e',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#fffdf8',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8a7d5e',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#ffe09b',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c2c2c1',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#ffe09b' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#f3e5ca' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#8ba9e4' })
  hi('TelescopeSelection',      { fg = '#fffdf8',          bg = '#262728' })
  hi('TelescopeSelectionCaret', { fg = '#ffe09b',             bg = '#262728' })
  hi('TelescopeMatching',       { fg = '#ffe09b',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#fffdf8',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#8a7d5e',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#fffdf8',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#ffe09b',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#ffe09b' })
  hi('MiniPickMatchCurrent',      { fg = '#fffdf8',          bg = '#262728' })
  hi('MiniPickPromptCaret', { fg = '#ffe09b',             bg = '#262728' })
  hi('MiniPickMatchRanges',       { fg = '#ffe09b',             bold = true })
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
