local noice = require("noice")
noice.setup({
    presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
    },
    lsp = {
        signature = {
            enabled = false,
        },
    },
})
