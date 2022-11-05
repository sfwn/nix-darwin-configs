--local builtin = require('telescope.builtin')
--vim.keymap.set('n', '<leader>o', builtin.find_files, {})
--vim.keymap.set('n', '<leader>f', builtin.live_grep, {})
--vim.keymap.set('n', '<leader>b', builtin.buffers, {})
----vim.keymap.set('n', 'fh', builtin.help_tags, {})
--vim.keymap.set('n', '<leader>p', builtin.commands, {})

local map = vim.keymap.set
local telescope = require('telescope')
local telescope_builtin = require('telescope.builtin')
local lga_actions = require("telescope-live-grep-args.actions")

vim.cmd([[
  highlight link TelescopePromptCounter TelescopeNormal
  highlight link TelescopeSelection TelescopePromptPrefix
]])

local previewers = require("telescope.previewers")

local new_maker = function(filepath, bufnr, opts)
  opts = opts or {}

  filepath = vim.fn.expand(filepath)
  vim.loop.fs_stat(filepath, function(_, stat)
    if not stat then return end
    if stat.size > 100000 then
      return
    else
      previewers.buffer_previewer_maker(filepath, bufnr, opts)
    end
  end)
end

local trouble = require("trouble.providers.telescope")

telescope.setup({
  defaults = {
    buffer_previewer_maker = new_maker,
    mappings = {
      i = {
        ["<c-t>"] = trouble.open_with_trouble,
      },
      n = {
        ["<c-t>"] = trouble.open_with_trouble,
      },
    },
  },
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
    fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
                                         -- the default case_mode is "smart_case"
    },
    coc = {
        -- theme = "ivy",
        prefer_locations = true, -- always use Telescope locations to preview definitions/declarations/implementations etc
    },
    live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- override default mappings
      -- default_mappings = {},
      mappings = { -- extend mappings
        i = {
          ["<C-k>"] = lga_actions.quote_prompt({ postfix = ' -t ' }),
          ["<C-q>"] = lga_actions.open_quickfix,
          ["<C-l>"] = lga_actions.open_loclist,
        },
      },
      -- ... also accepts theme settings, for example:
      -- theme = 'dropdown', -- use dropdown theme
      -- layout_config = { mirror=true }, -- mirror preview pane
    },
  },
})

-- To get telescope-file-browser loaded and working with telescope,
-- you need to call load_extension, somewhere after setup function:
telescope.load_extension('file_browser')
telescope.load_extension('project')
vim.api.nvim_set_keymap( 'n', '<Space>p', ":lua require'telescope'.extensions.project.project{}<CR>", {noremap = true, silent = true})
-- telescope.extensions.project.project{ display_type = 'full' }
telescope.load_extension('fzf')
telescope.load_extension('coc')
telescope.load_extension('live_grep_args')
telescope.load_extension('dap')

local set_keymap = function(lhs, rhs)
  map('n', lhs, rhs, { noremap = true })
end

--set_keymap('<leader>t', use_layout(telescope_builtin.builtin, 'popup_list'))
set_keymap('<leader>o', telescope_builtin.find_files)
set_keymap('<leader>b', telescope_builtin.buffers)
set_keymap('<leader>p', telescope_builtin.commands)
-- set_keymap('<leader>g', telescope_builtin.git_status) " use by fugitive
-- set_keymap('<leader>q', telescope_builtin.quickfix) " used by :q
set_keymap('<leader>l', telescope_builtin.current_buffer_fuzzy_find)
set_keymap('<F1>',      telescope_builtin.help_tags)
-- set_keymap('<leader>f', telescope_builtin.live_grep)
set_keymap('<leader>f', ':lua require("telescope").extensions.live_grep_args.live_grep_args{}<CR>')
