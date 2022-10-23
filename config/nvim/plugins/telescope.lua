--local builtin = require('telescope.builtin')
--vim.keymap.set('n', '<leader>o', builtin.find_files, {})
--vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
--vim.keymap.set('n', '<leader>b', builtin.buffers, {})
----vim.keymap.set('n', 'fh', builtin.help_tags, {})
--vim.keymap.set('n', '<leader>p', builtin.commands, {})

local map = vim.keymap.set
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')

vim.cmd([[
  highlight link TelescopePromptCounter TelescopeNormal
  highlight link TelescopeSelection TelescopePromptPrefix
]])


telescope.setup({
  extensions = {
  	file_browser = {
  		theme = "ivy",
  		-- disables netrw and use telescope-file-browser in its place
  		hijack_netrw = true,
  		mappings = {
  		  ["i"] = {
  		    -- your custom insert mode mappings
  		  },
  		  ["n"] = {
  		    -- your custom normal mode mappings
  		  },
  		},
  	},
  },
})

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension('file_browser')
telescope.load_extension('project')
vim.api.nvim_set_keymap( 'n', '<Space>p', ":lua require'telescope'.extensions.project.project{}<CR>", {noremap = true, silent = true})
-- telescope.extensions.project.project{ display_type = 'full' }

local set_keymap = function(lhs, rhs)
  map('n', lhs, rhs, { noremap = true })
end

--set_keymap('<leader>t', use_layout(telescope_builtin.builtin, 'popup_list'))
set_keymap('<leader>o', telescope_builtin.find_files)
set_keymap('<leader>b', telescope_builtin.buffers)
set_keymap('<leader>p', telescope_builtin.commands)
set_keymap('<leader>g', telescope_builtin.git_status)
set_keymap('<leader>q', telescope_builtin.quickfix)
set_keymap('<leader>l', telescope_builtin.loclist)
set_keymap('<F1>',      telescope_builtin.help_tags)
set_keymap('<leader>f', telescope_builtin.live_grep)
