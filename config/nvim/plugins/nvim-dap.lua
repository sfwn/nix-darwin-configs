-- """ go debug
-- let g:go_debug_mappings = {
--     \ '(go-debug-continue)': {'key': 'F5', 'arguments': '<nowait>'},
--     \ '(go-debug-next)': {'key': 'F8', 'arguments': '<nowait>'},
--     \ '(go-debug-step)': {'key': 'F7'},
--     \ '(go-debug-print)': {'key': 'p'},
-- \}
-- map <leader>ds :GoDebugStart<cr>
-- map <leader>dt :GoDebugStop<cr>
-- map <leader>db :GoDebugBreakpoint<cr>
--

local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

-- use nvim-dap events to open and close the windows automatically
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

dap.set_log_level('TRACE')

-- nvim-dap
-- Caveats: Goto insert mode and hit Ctrl-V Shift-F#, which gotted we can use that to map.
vim.keymap.set('n', '<f3>', dap.toggle_breakpoint, { noremap = true, silent = true })
vim.keymap.set('n', '<f15>', function() dap.set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, { noremap = true, silent = true }) -- <S-f3>
vim.keymap.set('n', '<space>ds', dap.continue, { noremap = true, silent = true }) -- start
vim.keymap.set('n', '<space>dc', dap.continue, { noremap = true, silent = true }) -- continue
vim.keymap.set('n', '<space>dx', dap.continue, { noremap = true, silent = true }) -- stop
vim.keymap.set('n', '<f7>', dap.step_over, { noremap = true, silent = true })
vim.keymap.set('n', '<f8>', dap.step_into, { noremap = true, silent = true })
vim.keymap.set('n', '<s-f8>', dap.step_out, { noremap = true, silent = true })
vim.keymap.set('n', '<space>di', dap.repl.open, { noremap = true, silent = true })
vim.keymap.set('n', '<space>dl', dap.run_last, { noremap = true, silent = true })

--- languages
-- go
require("dap-go").setup()
