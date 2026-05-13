vim.opt.runtimepath:prepend(vim.fn.expand('~/.config/nvim'))
vim.opt.runtimepath:append(vim.fn.expand('~/.local/share/nvim/lazy/rose-pine'))
vim.opt.runtimepath:append(vim.fn.expand('~/.local/share/nvim/lazy/csvview.nvim'))

require('config.keymaps')

require('rose-pine').setup({
  palette = require('config.palette'),
  variant = 'moon',
})
vim.cmd.colorscheme('rose-pine')
require('csvview').setup({})

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_user_command('Save', function(opts)
  local path = opts.args ~= '' and opts.args
    or vim.fn.expand('~/scratch/') .. os.date('%Y%m%d-%H%M%S') .. '.md'
  vim.fn.mkdir(vim.fn.fnamemodify(path, ':h'), 'p')
  vim.cmd('write ' .. vim.fn.fnameescape(path))
end, { nargs = '?' })

vim.bo.buftype, vim.bo.bufhidden = 'nofile', 'wipe'
vim.opt.swapfile = false
vim.opt.number = false
vim.opt.clipboard:append 'unnamedplus'
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.termguicolors = true

vim.g.mapleader = ' '
vim.keymap.set('n', '<Esc><Esc>', '<cmd>qa!<cr>', { desc = 'Close scratchpad' })

-- require 'config.keymaps'

-- require 'config.snippets'
