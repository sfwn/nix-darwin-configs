local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting

null_ls.setup({
    debug = true,
    sources = {
        formatting.goimports.with(
            {
                -- https://github.com/jose-elias-alvarez/null-ls.nvim/discussions/994#discussioncomment-3351235
                extra_args = function(params)
                    local cmd = string.format("head -1 %s/go.mod | awk '{print $2}'", params.root)
                    local output = vim.split(vim.fn.system(cmd), "\n")[1]
                    return { "-v", "-local", output }
                end,
            }
        ),
    },
})
