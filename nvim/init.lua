-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 1. DYNAMIC PATH HANDLING (Linux & Windows 11)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local data_path = vim.fn.stdpath('data') .. '/site/plugged'
local Plug = vim.fn['plug#']

vim.call('plug#begin', data_path)

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'airblade/vim-gitgutter'
Plug 'sjl/badwolf'
Plug 'vim-airline/vim-airline'
Plug 'fatih/vim-go'
Plug ('neoclide/coc.nvim', {branch = 'release'})
Plug 'preservim/nerdtree'

vim.call('plug#end')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 2. SYSTEM SETTINGS
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vim.g.mapleader = ','
vim.opt.number = true
vim.opt.relativenumber = true  -- The "Counting Fix"
vim.opt.scrolloff = 8          -- Keep context when scrolling
vim.opt.mouse = 'a'
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true       -- Case sensitive if capital used
vim.opt.expandtab = true       -- Use spaces
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.hidden = true          -- Switch buffers without saving
vim.cmd('syntax on')
pcall(vim.cmd, 'colorscheme badwolf')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 3. LETHAL KEYMAPPINGS
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts or {silent = true})
end

-- Project Navigation (Fuzzy Finder)
map('n', '<leader>f', ':Files<CR>')
map('n', '<leader>g', ':Rg<CR>')
map('n', '<leader>b', ':Buffers<CR>')
map('n', '<F3>', ':NERDTreeToggle<CR>')

-- LSP / Code Intelligence (Multi-file Jumping)
map('n', 'gd', '<Plug>(coc-definition)')     -- Jump to code
map('n', 'gr', '<Plug>(coc-references)')     -- Find all usages
map('n', 'K', ":call CocActionAsync('doHover')<CR>")
map('n', '[g', '<Plug>(coc-diagnostic-prev)') -- Jump to previous error
map('n', ']g', '<Plug>(coc-diagnostic-next)') -- Jump to next error

-- Window Management
map('n', '<leader>v', ':vsplit<CR>')
map('n', '<leader>h', ':split<CR>')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Clear Highlights
map('n', '<leader><space>', ':noh<CR>')

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 4. LANGUAGE SPECIFICS (Go)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        map('n', '<leader>r', '<Plug>(go-run)')
        map('n', '<leader>t', '<Plug>(go-test)')
    end
})
