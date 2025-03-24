return {
    "Mofiqul/adwaita.nvim",
    priority = 1000,                            -- Ensure it loads first
    config = function()
        vim.g.adwaita_darker = true             -- for darker version
        vim.g.adwaita_disable_cursorline = true -- to disable cursorline
        vim.g.adwaita_transparent = true        -- makes the background transparent
        vim.cmd('colorscheme adwaita')
    end
}
