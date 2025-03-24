return {
    "https://github.com/HiPhish/rainbow-delimiters.nvim",
    config = function()
        require("rainbow-delimiters.setup").setup({
            strategy = {
                -- ...
            },
            query = {
                -- ...
            },
            highlight = {
                -- ...
            },
        })
    end,
}
