local present, saga = pcall(require, "lspsaga")
if not present then return end

local setup = {
    code_action_lightbulb = {
        enable = true,
        sign = true,
        sign_priority = 20,
        virtual_text = false,
    },
    max_preview_lines = 10,
    finder_action_keys = {
        open = {"o", '<cr>'},
        vsplit = "s",
        split = "i",
        tabe = "t",
        quit = "q",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>",
    },
    code_action_keys = {
        quit = {"q", "<esc>"},
        exec = "<CR>",
    },
    rename_action_quit = "<C-c>",
    symbol_in_winbar = {
        in_custom = true,
        enable = true,
        separator = " > ",
        show_file = true,
        click_support = function(node, clicks, button)
            local st = node.range.start
            local en = node.range["end"]
            if button == "l" then
                if clicks == 2 then
                    vim.fn.cursor(st.line + 1, st.character + 1)
                    vim.cmd.normal "v"
                    vim.fn.cursor(en.line + 1, en.character + 1)
                else
                    vim.fn.cursor(st.line + 1, st.character + 1)
                end
            elseif button == "r" then
                vim.fn.cursor(en.line + 1, en.character + 1)
            elseif button == "m" then
                vim.fn.cursor(st.line + 1, st.character + 1)
                vim.cmd.normal "v"
                vim.fn.cursor(en.line + 1, en.character + 1)
            end
        end,
    },
    server_filetype_map = {},
}

saga.init_lsp_saga(setup)

local function get_file_name(include_path)
    local file_name = require("lspsaga.symbolwinbar").get_file_name()
    if vim.fn.bufname "%" == "" then return "" end
    if include_path == false then return file_name end
    -- Else if include path: ./lsp/saga.lua -> lsp > saga.lua
    local sep = vim.loop.os_uname().sysname == "Windows" and "\\" or "/"
    local path_list = vim.split(string.gsub(vim.fn.expand "%:~:.:h", "%%", ""), sep)
    local file_path = ""
    for _, cur in ipairs(path_list) do
        file_path = (cur == "." or cur == "~") and "" or file_path .. cur .. " " .. "%#LspSagaWinbarSep#>%*" .. " %*"
    end
    return file_path .. file_name
end

local function config_winbar()
    local exclude = {
        ["teminal"] = true,
        ["toggleterm"] = true,
        ["prompt"] = true,
        ["NvimTree"] = true,
        ["help"] = true,
    } -- Ignore float windows and exclude filetype
    if vim.api.nvim_win_get_config(0).zindex or exclude[vim.bo.filetype] then
        vim.wo.winbar = ""
    else
        local ok, lspsaga = pcall(require, "lspsaga.symbolwinbar")
        local sym
        if ok then sym = lspsaga.get_symbol_node() end
        local win_val = ""
        win_val = get_file_name(true) -- set to true to include path
        if sym ~= nil then win_val = win_val .. sym end
        vim.wo.winbar = win_val
    end
end

local events = { "BufEnter", "BufWinEnter", "CursorMoved" }

vim.api.nvim_create_augroup("UserLspsaga", { clear = true })

vim.api.nvim_create_autocmd(events, {
    group = "UserLspsaga",
    pattern = "*",
    callback = function() config_winbar() end,
})

vim.api.nvim_create_autocmd("User", {
    group = "UserLspsaga",
    pattern = "LspsagaUpdateSymbol",
    callback = function() config_winbar() end,
})

-- keymaps
-- Lsp finder find the symbol definition implement reference
-- if there is no implement it will hide
-- when you use action in finder like open vsplit then you can
-- use <C-t> to jump back
vim.keymap.set("n", "gh", "<cmd>Lspsaga lsp_finder<CR>", { silent = true })
vim.keymap.set("n", "gq", "<cmd>Lspsaga code_action<CR>", { silent = true })
