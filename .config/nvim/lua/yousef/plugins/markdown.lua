return {
    'MeanderingProgrammer/markdown.nvim',
    name = 'render-markdown',                                                      -- Only needed if you have another plugin named markdown.nvim
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim'}, -- if you use the mini.nvim suite
    config = function()
        require('render-markdown').setup({})
    end,
}
