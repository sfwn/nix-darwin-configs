local navic = require('nvim-navic')
local navic_location = function ()
    -- get current buffer filename
    local filename = vim.fn.expand('%:t')
    local has_lsp_attached = false
    vim.lsp.for_each_buffer_client(0, function(client, _, _)
        has_lsp_attached = true
    end)
    if not has_lsp_attached then
        return ''
    end
    local location = navic.get_location()
    if #location > 0 then
        return string.format('%s > %s', filename, location)
    else
        return string.format('%s', filename)
    end

end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    section_separators = { left = '', right = '' },
    component_separators = { left = '', right = '' },
    -- component_separators = { left = '', right = ''},
    -- section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = true,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {},
    lualine_c = {'progress', 'location', 'diagnostics'},
    -- lualine_b = {'branch', 'diff', 'diagnostics', 'filename' },
    -- lualine_c = { navic.get_location },
    lualine_x = {'branch'},
    -- lualine_y = { 'filetype', 'encoding', 'progress'},
    lualine_y = {},
    lualine_z = {'filename'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {
      lualine_c = { { navic_location } },
  },
  inactive_winbar = {},
  extensions = {}
}
