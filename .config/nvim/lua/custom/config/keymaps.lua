local map = vim.keymap.set

map('i', 'kj', '<ESC>')
map({ 'n', 'i', 'v' }, '<C-d>', '<C-d>zz')
map({ 'n', 'i', 'v' }, '<C-u>', '<C-u>zz')
map('n', 'n', 'nzzzv')
map('n', 'N', 'Nzzzv')
map('n', '<TAB>', ':bnext<CR>')
map('n', '<S-TAB>', ':bprevious<CR>')
map('n', '<leader>x', ':bdelete<CR>')
map({ 'n', 'i', 'v' }, '<C-/>', '<Plug>(comment_toggle_linewise)')

map({ 'n', 'i', 'v' }, '<C-s>', '<cmd> w <cr>')
