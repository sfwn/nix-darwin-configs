require("catppuccin").setup({
    flavour = "frappe", -- latte, frappe, macchiato, mocha
    background = { -- :h background
        light = "latte",
        dark = "frappe",
    },
    transparent_background = false,
    term_colors = true,
    integrations = {
        cmp = true,
        gitsigns = true,
        fidget = true,
        leap = true,
        lsp_trouble = true,
        nvimtree = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
        lsp_saga = true,
        navic = {
            enabled = true,
            custom_bg = "NONE",
        },
        indent_blankline = {
            enabled = true,
            colored_indent_levels = true,
        },
        dap = {
            enabled = true,
            enable_ui = true, -- enable nvim-dap-ui
        },
        native_lsp = {
            enabled = true,
            virtual_text = {
                errors = { "italic" },
                hints = { "italic" },
                warnings = { "italic" },
                information = { "italic" },
            },
            underlines = {
                errors = { "underline" },
                hints = { "underline" },
                warnings = { "underline" },
                information = { "underline" },
            },
        },
    }
})

-- fidget
require("fidget").setup({
    window = {
        blend = 0,
    }
})

-- dap
-- You NEED to override nvim-dap's default highlight groups, AFTER requiring nvim-dap
require("dap")

local sign = vim.fn.sign_define

sign("DapBreakpoint", { text = "●", texthl = "DapBreakpoint", linehl = "", numhl = "" })
sign("DapBreakpointCondition", { text = "●", texthl = "DapBreakpointCondition", linehl = "", numhl = "" })
sign("DapLogPoint", { text = "◆", texthl = "DapLogPoint", linehl = "", numhl = "" })

-- navic
require("nvim-navic").highlight = true

-- setup
vim.api.nvim_command "colorscheme catppuccin"
