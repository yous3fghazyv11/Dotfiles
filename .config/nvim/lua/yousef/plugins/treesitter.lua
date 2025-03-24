return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
        local configs = require("nvim-treesitter.configs")
        configs.setup({
            ensure_installed = { "c", "cpp", "lua" },
            sync_install = false,
            indent = { enable = true },
            highlight = {
                enable = true,
            },
            incremental_selection = { enable = true },
            autotag = { enable = true },
            rainbow = { enable = true, disable = { "html" }, extended_mode = false },
        })
    end,
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-textobjects" },
        {
            "nvim-treesitter/nvim-treesitter-context",
        },
        { "windwp/nvim-ts-autotag" },
        { "HiPhish/rainbow-delimiters.nvim" },
        { "JoosepAlviste/nvim-ts-context-commentstring" },
    },
}
