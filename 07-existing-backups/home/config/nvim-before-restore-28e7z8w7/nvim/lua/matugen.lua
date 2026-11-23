 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#000000',
    base01 = '#0c192c',
    base02 = '#112239',
    base03 = '#59779d',
    base04 = '#bcc1c8',
    base05 = '#f6faff',
    base06 = '#f6faff',
    base07 = '#f6faff',
    base08 = '#ff5c78',
    base09 = '#e8f79c',
    base0A = '#d5eeff',
    base0B = '#84baff',
    base0C = '#e4f589',
    base0D = '#80b7ff',
    base0E = '#7fcbff',
    base0F = '#b3e0ff',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  -- telescope.nvim
  hi('TelescopeNormal',         { fg = '#f6faff',          bg = '#000000' })
  hi('TelescopeBorder',         { fg = '#59779d',             bg = '#000000' })
  hi('TelescopePromptNormal',   { fg = '#f6faff',          bg = '#000000' })
  hi('TelescopePromptBorder',   { fg = '#59779d',             bg = '#000000' })
  hi('TelescopePromptPrefix',   { fg = '#84baff',             bg = '#000000' })
  hi('TelescopePromptCounter',  { fg = '#bcc1c8',  bg = '#000000' })
  hi('TelescopePromptTitle',    { fg = '#000000',             bg = '#84baff' })
  hi('TelescopePreviewTitle',   { fg = '#000000',             bg = '#d5eeff' })
  hi('TelescopeResultsTitle',   { fg = '#000000',             bg = '#e8f79c' })
  hi('TelescopeSelection',      { fg = '#f6faff',          bg = '#112239' })
  hi('TelescopeSelectionCaret', { fg = '#84baff',             bg = '#112239' })
  hi('TelescopeMatching',       { fg = '#84baff',             bold = true })

  -- mini.pick
  hi('MiniPickNormal',         { fg = '#f6faff',          bg = '#000000' })
  hi('MiniPickBorder',         { fg = '#59779d',             bg = '#000000' })
  hi('MiniPickPrompt',   { fg = '#f6faff',          bg = '#000000' })
  hi('MiniPickPromptPrefix',   { fg = '#84baff',             bg = '#000000' })
  hi('MiniPickBorderText',    { fg = '#000000',             bg = '#84baff' })
  hi('MiniPickMatchCurrent',      { fg = '#f6faff',          bg = '#112239' })
  hi('MiniPickPromptCaret', { fg = '#84baff',             bg = '#112239' })
  hi('MiniPickMatchRanges',       { fg = '#84baff',             bold = true })
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
