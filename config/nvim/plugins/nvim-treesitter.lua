require'nvim-treesitter.configs'.setup {
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	incremental_selection = {
        	enable = true,
        },
	indent = {
		enable = true,
	},
}
-- Highlight the @foo.bar capture group with the "Identifier" highlight group
vim.api.nvim_set_hl(0, "@foo.bar", { link = "Identifier" })
