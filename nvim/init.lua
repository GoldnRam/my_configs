-- Cross-Platform Neovim Config
-- Documentation & Mappings: https://github.com/GoldnRam/my_configs/blob/main/README.md

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
vim.opt.timeoutlen = 1000
vim.cmd('syntax on')
pcall(vim.cmd, 'colorscheme badwolf')

-- Windows-specific Shell Configuration
if vim.fn.has('win32') == 1 then
    vim.opt.shell = 'powershell.exe'
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
end

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 3. KEYMAPPINGS
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
local function map(mode, lhs, rhs, opts)
    vim.keymap.set(mode, lhs, rhs, opts or {silent = true})
end

-- Project Navigation (Fuzzy Finder)
map('n', '<leader>f', ':Files<CR>')
map('n', '<leader>g', ':Rg<CR>')
map('n', '<leader>b', ':Buffers<CR>')
map('n', '<F3>', ':NERDTreeToggle<CR>')

-- LSP / Code Intelligence
map('n', 'gd', '<Plug>(coc-definition)')     -- Jump to code
map('n', 'gr', '<Plug>(coc-references)')     -- Find all usages
map('n', 'K', ":call CocActionAsync('doHover')<CR>")
map('n', '[g', '<Plug>(coc-diagnostic-prev)') -- Jump to previous error
map('n', ']g', '<Plug>(coc-diagnostic-next)') -- Jump to next error
map('n', '<leader>a', '<Plug>(coc-codeaction-cursor)') -- Quick Fix

-- Autocomplete Logic (Tab to navigate, Enter to confirm)
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = {expr = true, replace_keycodes = false}
map("i", "<Tab>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<Tab>" : coc#refresh()', opts)
map("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
map("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
map("i", "<c-space>", "coc#refresh()", opts)

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
-- 4. TERMINAL DRAWER (Ctrl + \)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
map('t', '<Esc>', [[<C-\><C-n>]]) -- Exit terminal mode

function _G.toggle_terminal()
    local term_buf = nil
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == 'terminal' then
            term_buf = buf
            break
        end
    end

    if term_buf then
        local term_win = vim.fn.bufwinnr(term_buf)
        if term_win > 0 then
            vim.cmd(term_win .. 'hide')
        else
            vim.cmd('botright split | buffer ' .. term_buf)
            vim.cmd('resize 10')
            vim.cmd('startinsert')
        end
    else
        local shell = vim.fn.has('win32') == 1 and 'powershell.exe' or 'bash'
        vim.cmd('botright 10split term://' .. shell)
        vim.cmd('startinsert')
    end
end

-- Mapped to Ctrl + \ (The standard terminal toggle)
map('n', '<C-\\>', ':lua toggle_terminal()<CR>')
map('t', '<C-\\>', [[<C-\><C-n>:lua toggle_terminal()<CR>]])

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 5. LANGUAGE SPECIFICS (Go)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
vim.g.go_def_mapping_enabled = 0
vim.g.go_textobj_enabled = 0

-- LETHAL FIX: Use a split terminal for execution to prevent freezing
vim.g.go_term_enabled = 1
vim.g.go_term_mode = "split" 

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        map('n', '<leader>r', '<Plug>(go-run)')
        map('n', '<leader>t', '<Plug>(go-test)')
    end
})
