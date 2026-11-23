 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#210e32',
    base02 = '#2a1340',
    base03 = '#8c5da4',
    base04 = '#c4bcca',
    base05 = '#fcf6ff',
    base06 = '#fcf6ff',
    base07 = '#fcf6ff',
    base08 = '#ff5c78',
    base09 = '#c2a7ff',
    base0A = '#ffe5ae',
    base0B = '#d87cff',
    base0C = '#a780ff',
    base0D = '#d980ff',
    base0E = '#ffd680',
    base0F = '#ffe6b3',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#fcf6ff',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#8c5da4',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#fcf6ff',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#8c5da4',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#d87cff',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#c4bcca',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#d87cff' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#ffe5ae' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#c2a7ff' })
  hi('TelescopeSelection',      { fg = '#fcf6ff',          bg = '#2a1340' })
  hi('TelescopeSelectionCaret', { fg = '#d87cff',             bg = '#2a1340' })
  hi('TelescopeMatching',       { fg = '#d87cff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#fcf6ff',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#8c5da4',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#fcf6ff',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#d87cff',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#d87cff' })
  hi('MiniPickMatchCurrent',      { fg = '#fcf6ff',          bg = '#2a1340' })
  hi('MiniPickPromptCaret', { fg = '#d87cff',             bg = '#2a1340' })
  hi('MiniPickMatchRanges',       { fg = '#d87cff',             bold = true })
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
