local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

vim.g.mapleader = " "


keymap("n", "<leader>e", ":Neotree toggle<cr>", opts)
keymap("n", "<ESC>", ":noh<cr>", opts)
-- keymap("n", ";", ":", opts)

keymap("n", "<leader>wv", "<C-w>v", opts)
keymap("n", "<leader>wc", "<C-w>c", opts)
keymap("n", "<leader>wh", "<C-w>h", opts)
keymap("n", "<leader>wl", "<C-w>l", opts)

-- better innsert mode navigation
keymap("i", "<A-l>", "<Right>", opts)
keymap("i", "<A-h>", "<Left>", opts)
keymap("i", "<A-j>", "<Down>", opts)
keymap("i", "<A-k>", "<Up>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

keymap("i", "jk", "<ESC>", opts)
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("n", "<leader>lf", vim.lsp.buf.format)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>c", [["hy:%s/<C-r>h/<C-r>h/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>C", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gcI<Left><Left><Left>]])
vim.keymap.set("v", "<leader>c", [["hy:%s/<C-r>h/<C-r>h/gcI<Left><Left><Left>]])
vim.keymap.set("n", "<A-i>", function()
    require("nvterm.terminal").toggle "float"
end
)
vim.keymap.set("t", "<A-i>", function()
    require("nvterm.terminal").toggle "float"
end
)

vim.keymap.set("t", "<A-p>", '"+p')

-- vim.keymap.set('n', '<leader>ff', [[:Telescope find_files <CR>]])
vim.api.nvim_set_keymap('n', '<Leader>ff', ':lua require"telescope.builtin".find_files({ hidden = true })<CR>',
    { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', [[:Telescope live_grep <CR>]])
vim.keymap.set('n', '<leader>bb', [[:Telescope buffers <CR>]])
vim.keymap.set('n', '<leader>fh', [[:Telescope help_tags <CR>]])
vim.keymap.set('n', '<leader>bk', [[:bdelete]])

vim.keymap.set("n", "<A-l>", "$")
vim.keymap.set("n", "<A-h>", "^")
vim.keymap.set("v", "<A-l>", "$h")
vim.keymap.set("v", "<A-h>", "^")
vim.keymap.set("n", "<leader>bk", ":bdelete<cr>")

vim.keymap.set('n', "<leader>/", [[:Telescope current_buffer_fuzzy_find <CR>]])
vim.keymap.set('n', "<leader>fc", [[:Oil /home/yusif/.config/nvim/lua/yousef/ <CR>]])
vim.keymap.set('n', "<leader>p", '"+p')

-- latex
vim.keymap.set('v', "<leader>inc", "c\"\"<ESC>i\\mintinline{C}<esc>a{}<esc>hp<esc>")
vim.keymap.set('n', "<leader>blc", "i\\begin{minted}[bgcolor=bg]{C}<CR><BS>\\end{minted}<esc>O")
vim.keymap.set('n', "<leader>fig",
    "i\\begin{figure}[h]<CR><BS>\\centering<CR><CR><BS>\\includegraphics{}<CR><CR><BS>\\end{figure}<esc>k$h")
vim.keymap.set('n', "<leader>ty",
    "i\\begin{tcolorbox}[trythis]<CR><BS>\\textcolor{red}{Try This:}<CR><CR>\\end{tcolorbox}<ESC>k")
vim.keymap.set('n', "<leader>lin", [[:InlayHintsToggle<CR>]])
vim.keymap.set('n', "<leader>sl", "i\\sectionlinetwo{DarkGreen}{88}<ESC>")
