-- examples for your init.lua

-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- OR setup with some options
require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    adaptive_size = true,
    mappings = {
      list = {
        { key = "u", action = "dir_up" },
      },
    },
  },
  renderer = {
    group_empty = true,
  },
  filters = {
    dotfiles = false,
    custom = {
            "node_modules", "^\\.git/",
    },
  },
  git = {
        enable = true,
        ignore = true,
    },  
  sync_root_with_cwd = true,
  respect_buf_cwd = true,
  update_focused_file = {
    enable = true,
    update_root = false,
  },
})

vim.g.nvim_tree_highlight_opened_files = 1
vim.api.nvim_set_keymap("n", "<leader>1", ":NvimTreeFindFileToggle!<CR>", { noremap = true, silent = true })
