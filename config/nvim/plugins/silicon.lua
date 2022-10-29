require("silicon").setup({
    output = string.format(
        "%s/ScreenShots/SILICON_%s-%s-%s_%s-%s-%s.png",
        os.getenv("HOME"), os.date("%Y"), os.date("%m"), os.date("%d"), os.date("%H"), os.date("%M"), os.date("%S")
    ),
    font = "JetBrainsMono Nerd Font Mono",
})
