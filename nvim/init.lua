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
vim.cmd('syntax on')
pcall(vim.cmd, 'colorscheme badwolf')

-- Windows-specific Shell Configuration
if vim.fn.has('win32') == 1 then
    vim.opt.shell = 'powershell.exe'
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
end

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
map('n', '<leader>a', '<Plug>(coc-codeaction-cursor)') -- Quick Fix (Code Action)

-- Autocomplete Logic (Tab to navigate, Enter to confirm)
function _G.check_back_space()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

local opts = {expr = true, replace_keycodes = false}
map("i", "<Tab>", 'coc#pum#visible() ? coc#pum#next(1) : v:lua.check_back_space() ? "<Tab>" : coc#refresh()', opts)
map("i", "<S-Tab>", [[coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"]], opts)
map("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"]], opts)
map("i", "<c-space>", "coc#refresh()", opts) -- Ctrl+Space to trigger manually

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
-- 4. TERMINAL DRAWER (VS Code Style)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Exit terminal mode easily to scroll output
map('t', '<Esc>', [[<C-\><C-n>]])

-- Toggle Terminal Logic
function _G.toggle_terminal()
    local term_buf = nil
    -- Check if a terminal buffer already exists
    for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.bo[buf].buftype == 'terminal' then
            term_buf = buf
            break
        end
    end

    if term_buf then
        -- If found, check if it's currently visible
        local term_win = vim.fn.bufwinnr(term_buf)
        if term_win > 0 then
            vim.cmd(term_win .. 'hide') -- Hide it
        else
            vim.cmd('botright split | buffer ' .. term_buf) -- Show it
            vim.cmd('resize 10')
            vim.cmd('startinsert') -- Auto-enter insert mode
        end
    else
        -- Create new terminal (Detect OS for Shell)
        local shell = vim.fn.has('win32') == 1 and 'powershell.exe' or 'bash'
        vim.cmd('botright 10split term://' .. shell)
        vim.cmd('startinsert')
    end
end

-- Mapped to ',sh' to avoid conflict with GoTest (,t)
map('n', '<leader>sh', ':lua toggle_terminal()<CR>')
map('t', '<leader>sh', [[<C-\><C-n>:lua toggle_terminal()<CR>]]) -- Work inside terminal too

-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- 5. LANGUAGE SPECIFICS (Go)
-- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Disable vim-go default mappings to prevent conflicts
vim.g.go_def_mapping_enabled = 0
vim.g.go_textobj_enabled = 0

vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    callback = function()
        map('n', '<leader>r', '<Plug>(go-run)')  -- Run
        map('n', '<leader>t', '<Plug>(go-test)') -- Test
    end
})
