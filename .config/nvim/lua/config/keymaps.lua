--- custom keymaps --
local map = vim.keymap.set

-- Vim motion keymaps
map('i', 'kj', '<ESC>', { noremap = true })
map({ 'n', 'v' }, 'gl', 'L')
map({ 'n', 'v' }, 'L', '%')
map({ 'n', 'v' }, 'J', '<C-e>j')
map({ 'n', 'v' }, 'K', '<C-y>k')
map({ 'n', 'v' }, 'gh', 'H')
map({ 'n', 'v' }, 'H', 'J')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', 'zk', 'zt')
map('n', 'zj', 'zb')
-- map({ 'n', 'v' }, '<C-e>', 'J')
map({ 'n', 'v' }, '<C-d>', '<C-d>zz')
map({ 'n', 'v' }, '<C-u>', '<C-u>zz')
map('n', '<Esc>', '<cmd>nohlsearch<CR>')

map({ 'n' }, '<leader>xx', ':noautocmd w<bar>:!python %<CR>', { desc = 'python main.py' })

-- yank / delete / visual behavior
map('n', '<leader>.', 'viw', { noremap = true, silent = true })
map('n', '<leader>d.', 'diwsdb', { noremap = false, silent = true })
map('n', '<leader>y', 'yiw', { noremap = true, silent = true })
map('n', '<leader>y', 'yiw', { noremap = true, silent = true })
map('n', '<leader>w', 'yiw', { noremap = true, silent = true })
map('v', '<leader>p', '"_dP')
map({ 'n', 'v' }, '<leader>d', '"_d')
-- map({ 'n', 'i', 'v' }, '<C-_>', '<Plug>(comment_toggle_linewise)')

-- Buffer related
map({ 'n', 'i', 'v' }, '<C-s>', '<cmd>noautocmd w<cr>', { noremap = true, desc = 'Save current buffer (without formatting)' })
map('n', '<leader>q', ':bdelete<CR>', { noremap = true, desc = 'Close current buffer' })
map({ 'n', 'v' }, '<Leader>n', ':enew<CR>', { noremap = true, silent = true, desc = 'New buffer' })
map({ 'n', 'v' }, '<Leader>v', ':vsplit<CR>', { noremap = true, silent = true, desc = 'New vertical split' })
map({ 'n', 'v' }, '<Leader>tn', ':tabnew<CR>', { noremap = true, silent = true, desc = 'New vertical split' })
map({ 'n', 'v' }, '<Tab>', ':lua ToggleBuffers()<CR>', { noremap = true, silent = true, desc = 'Last buffer' })
map('n', '<Leader>rm', 'mz:%s/\\r//g<CR>`z', { desc = 'Remove Carriage Returns From Buffer' })

map({ 'n', 'v' }, '<Leader>rr', function()
      vim.cmd('e!')
      vim.cmd('LspRestart')
      vim.cmd([[echo "file reloaded"]])
    end, {
      noremap = true,
      desc = 'Force reload current buffer (discard any changes)',
    })

-- Plugin specific keymaps
-- map('n', '<leader>i', ':lua require("iris").toggle_quick_menu()<CR>', { noremap = true, silent = true })
-- map('n', '<leader>co', ':lua require("iris").prompt_openai()<CR>', { noremap = true, silent = true })
-- map('n', '<leader>cc', ':lua require("iris").prompt_claudeai()<CR>', { noremap = true, silent = true })

-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [d]iagnostic [E]rror messages' })
map('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [d]iagnostic [q]uickfix list' })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- <Tab> will only switch between two files
function ToggleBuffers()
  local current = vim.fn.bufnr '%'
  local last = vim.fn.bufnr '#'
  if last ~= -1 and last ~= current then
    vim.cmd('buffer ' .. last)
  end
end
