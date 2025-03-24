require("yousef.core")
require("yousef.lazy")

vim.env.FZF_DEFAULT_COMMAND = 'ag --hidden --ignore .git -l -g ""'

-- Neovide
if vim.g.neovide then
    vim.o.guifont = "JetBrainsMono Nerd Font:h14" -- text below applies for VimScript
    vim.g.neovide_transparency = 1
    vim.g.transparency = 0.88

    vim.g.neovide_cursor_vfx_opacity = 0
    vim.g.neovide_refresh_rate = 160
end

vim.cmd [[
let g:codeium_manual = v:true

" You might want to use `CycleOrComplete()` instead of `CycleCompletions(1)`.
" This will make the forward cycling of suggestions also trigger the first
" suggestion manually.
imap <C-;> <Cmd>call codeium#CycleOrComplete()<CR>
]]

