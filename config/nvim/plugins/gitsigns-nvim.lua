require("gitsigns").setup({
    signcolumn = true,
    numhl = true,
    linehl = false,
    word_diff = false,
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
        delay = 1000,
        ignore_whitespace = false,
    },
    current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> • <summary>',
    attach_to_untracked = true,
})

vim.cmd [[ nnoremap [c :Gitsigns prev_hunk<CR>" ]]
vim.cmd [[ nnoremap ]c :Gitsigns next_hunk<CR>" ]]
