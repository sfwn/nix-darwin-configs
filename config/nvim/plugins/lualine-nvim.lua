local lualine = require('lualine')

lualine.setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
        -- theme = 'catppuccin',
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
        lualine_a = { 'mode' },
        lualine_b = {},
        lualine_c = { 'progress', 'location', '%=', 'diagnostics' },
        lualine_x = { 'branch', 'diff' },
        lualine_y = { 'filetype' },
        lualine_z = {
            {
                'filename',
                file_status = true,
                newfile_status = true,
                path = 0,
            },
        }
    },
    inactive_sections = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = { 'filename' },
        lualine_x = { 'location' },
        lualine_y = {},
        lualine_z = {}
    },
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = {}
}
