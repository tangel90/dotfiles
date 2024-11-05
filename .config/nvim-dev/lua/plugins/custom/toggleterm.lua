return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {},
  config = function(_, opts)
    require('toggleterm').setup(opts)
    vim.keymap.set('n', '<Leader>t', ':ToggleTerm <CR>', { noremap = true, silent = true })
  end,
}
