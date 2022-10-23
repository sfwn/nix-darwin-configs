require'FTerm'.setup({
    border = 'double',
    dimensions  = {
        height = 0.9,
        width = 0.9,
    },
})

-- Example keybindings
vim.keymap.set('n', '<A-i>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<A-i>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

local fterm = require("FTerm")

-- lazygit
local lazygit = fterm:new({
    cmd = "lazygit",
    dimensions = {
        height = 0.9,
        width = 0.9,
    },
})
-- Use this to toggle lazygit in a floating terminal
vim.keymap.set('n', '<A-g>', function()
    lazygit:toggle()
end)

-- btop
local btop = fterm:new({
    ft = 'fterm_btop',
    cmd = "btop"
})
 -- Use this to toggle btop in a floating terminal
vim.keymap.set('n', '<A-b>', function()
    btop:toggle()
end)
