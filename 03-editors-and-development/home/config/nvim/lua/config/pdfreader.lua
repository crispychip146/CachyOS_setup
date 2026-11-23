local M = {}

function M.setup()
  if M.configured then
    return
  end
  M.configured = true

  local ImagePage = require("pdfreader.pages.image")
  local TextPage = require("pdfreader.pages.text")
  local Image = require("pdfreader.image")
  local Book = require("pdfreader.book")
  local placement = require("snacks.image.placement")

  -- Upstream constructs image pages on the shared class table. Give every
  -- page its own instance so navigation and caching do not overwrite it.
  local new_page = ImagePage.new
  function ImagePage:new(filepath, page, opts)
    return new_page(setmetatable({}, ImagePage), filepath, page, opts)
  end

  -- A page turn must replace the previous terminal image, rather than leave
  -- multiple page placements stacked at the same buffer position.
  local display_image = Image.display
  function Image:display(buf, scale)
    placement.clean(buf)
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "" })
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    return display_image(self, buf, scale)
  end

  local render_text = TextPage.render
  function TextPage:render(buf, scale)
    placement.clean(buf)
    return render_text(self, buf, scale)
  end

  -- Next/previous navigation asks for the same page twice. Reuse it, and
  -- regenerate only when the view mode changes.
  local get_page = Book.get_page
  function Book:get_page(number, opts)
    local cached = self.pages[tostring(number)]
    if cached and cached.color_mode == opts.mode then
      return cached
    end
    return get_page(self, number, opts)
  end

  -- Lualine replaces the plugin's native statusline, so expose its page state
  -- to the component configured in plugins/documents.lua.
  local show_statusline = Book.show_statusline
  function Book:show_statusline(buf, opts)
    vim.b[buf].pdfreader_progress = { page = self.current_page_number, total = self.number_of_pages }
    return show_statusline(self, buf, opts)
  end

  require("pdfreader").setup()
  vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("personal_pdf_navigation", { clear = true }),
    pattern = "*.pdf",
    callback = function(ev)
      local opts = { buffer = ev.buf, remap = true, silent = true }
      vim.keymap.set("n", "<PageDown>", "n", vim.tbl_extend("force", opts, { desc = "Next PDF Page" }))
      vim.keymap.set("n", "<PageUp>", "p", vim.tbl_extend("force", opts, { desc = "Previous PDF Page" }))
      vim.keymap.set("n", "]p", "n", vim.tbl_extend("force", opts, { desc = "Next PDF Page" }))
      vim.keymap.set("n", "[p", "p", vim.tbl_extend("force", opts, { desc = "Previous PDF Page" }))
    end,
  })
end

function M.status()
  local progress = vim.b.pdfreader_progress
  return progress and ("PDF %d/%d"):format(progress.page, progress.total or 0) or ""
end

return M
