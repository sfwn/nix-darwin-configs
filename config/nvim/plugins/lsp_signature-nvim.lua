require("lsp_signature").setup({
    -- For now, as this would hide parts of autocomplete
    floating_window = false,
})
require("lsp_signature").status_line(max_width)
