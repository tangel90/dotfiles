vim.opt.runtimepath:prepend(vim.fn.expand('~/.config/nvim'))
vim.opt.runtimepath:append(vim.fn.expand('~/.local/share/nvim/lazy/rose-pine'))
vim.opt.runtimepath:append(vim.fn.expand('~/.local/share/nvim/lazy/csvview.nvim'))

require('config.keymaps')

-- Light theme here on purpose, so a scratchpad is unmistakable next to the
-- main config. `background = light` matters as well as the variant: rose-pine
-- keys some highlights off it, and nvim otherwise inherits 'dark' from the
-- terminal. config.palette only overrides the main/moon variants, so dawn uses
-- rose-pine's own light colours.
require('rose-pine').setup({
  palette = require('config.palette'),
  variant = 'dawn',
  dark_variant = 'main',
})
vim.o.background = 'light'
vim.cmd.colorscheme('rose-pine-dawn')
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

-- Start in insert mode for a fresh (empty) scratchpad. When content is piped
-- in (e.g. `open-pass show`), the buffer is non-empty so we stay in normal.
vim.api.nvim_create_autocmd('VimEnter', {
  callback = function()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines <= 1 and (lines[1] or '') == '' then
      vim.cmd.startinsert()
    end
  end,
})

-- require 'config.keymaps'

-- require 'config.snippets'
