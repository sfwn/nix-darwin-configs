require('leap').add_default_mappings()

-- Disable auto-jumping to the first match
require('leap').opts.safe_labels = {}

-- bidirectional search
-- require('leap').leap { target_windows = { vim.fn.win_getid() } }

-- search in all windows
-- require('leap').leap { target_windows = vim.tbl_filter(
--   function (win) return vim.api.nvim_win_get_config(win).focusable end,
--   vim.api.nvim_tabpage_list_wins(0)
-- )}

-- How to live without `s`/`S`/`x`/`X`?
-- s = cl
-- S = cL
