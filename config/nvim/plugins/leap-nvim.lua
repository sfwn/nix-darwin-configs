-- require('leap').add_default_mappings()

-- How to live without `s`/`S`/`x`/`X`?
-- s = cl
-- S = cL

local leap = require("leap")

local function search_all()
    leap.leap({
        opts = {
            -- Disable auto-jumping to the first match
            safe_labels = {},
        },
        target_windows = vim.tbl_filter(
            function(win) return vim.api.nvim_win_get_config(win).focusable end,
            vim.api.nvim_tabpage_list_wins(0)
        ),
    })
end

-- custom mapping
vim.keymap.set({ 'n', 'x', 'o' }, '<C-s>', search_all, { noremap = true })
