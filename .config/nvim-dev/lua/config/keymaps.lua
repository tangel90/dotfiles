--- custom keymaps --
local map = vim.keymap.set

map('i', 'kj', '<ESC>')
map({ 'n', 'v' }, 'L', '%')
map({ 'n', 'v' }, 'J', 'L')
map({ 'n', 'v' }, 'K', 'H')
map({ 'n', 'v' }, 'H', 'J')
map({ 'n', 'v' }, '<C-e>', 'J')

-- map({ 'n', 'i' }, '<C-x>', ':!dotnet run<CR>')
map({ 'n', 'i' }, '<C-x>', ':!python %<CR>')

map({ 'n', 'v' }, '<C-d>', '<C-d>zz')
map({ 'n', 'v' }, '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<leader>x', ':bdelete<CR>', { desc = 'Close current buffer' })
-- map({ 'n', 'i', 'v' }, '<C-/>', '<Plug>(comment_toggle_linewise)')

map({ 'n', 'i', 'v' }, '<C-s>', '<cmd> w <cr>')

map('v', '<leader>p', '"_dP')
map('n', '<leader>d', '"_d')
map('v', '<leader>d', '"_d')

map('n', 'zk', 'zt')
map('n', 'zj', 'zb')

vim.api.nvim_set_keymap('n', '<Tab>', ':lua ToggleBuffers()<CR>', { noremap = true, silent = true })

-- <Tab> will only switch between two files
function ToggleBuffers()
  local current = vim.fn.bufnr '%'
  local last = vim.fn.bufnr '#'
  if last ~= -1 and last ~= current then
    vim.cmd('buffer ' .. last)
  end
end

-- Kickstart Keymaps
-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

vim.api.nvim_set_keymap('n', '<leader>i', ':lua require("iris").toggle_quick_menu()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>co', ':lua require("iris").prompt_openai()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>cc', ':lua require("iris").prompt_claudeai()<CR>', { noremap = true, silent = true })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle)
-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
