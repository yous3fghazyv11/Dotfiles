return {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
        indent = {
            char = "│",
            tab_char = ".",
        },
        scope = { enabled = false },
        exclude = {
            filetypes = {
                "help",
                "alpha",
                "dashboard",
                "neo-tree",
                "Trouble",
                "trouble",
                "lazy",
                "mason",
                "notify",
                "toggleterm",
                "lazyterm",
            },
        },
    },
    main = "ibl",
    config = function()
        local highlight = {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        }

        local hooks = require "ibl.hooks"
        -- create the highlight groups in the highlight setup hook, so they are reset
        -- every time the colorscheme changes
        hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
            vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#FF9999" })
            vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#99FF99" })
            vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#9999FF" })
            vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#FFFF99" })
            vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#FFD1A5" })
            vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#D1B3E2" })
            vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#99FFFF" })
        end)

        require("ibl").setup { indent = { highlight = highlight } }
    end
}
