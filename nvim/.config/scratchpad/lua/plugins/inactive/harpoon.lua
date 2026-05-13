return {
  'ThePrimeagen/harpoon',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  config = function()
    local mark = require 'harpoon.mark'
    local ui = require 'harpoon.ui'

    vim.keymap.set('n', '<leader>a', mark.add_file, { desc = 'Add current file to Harpoon' })
    vim.keymap.set('n', '<leader>o', ui.toggle_quick_menu, { desc = 'Toggle Harpoon quick menu' })

    vim.keymap.set('n', '<leader>1', function()
      ui.nav_file(1)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>2', function()
      ui.nav_file(2)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>3', function()
      ui.nav_file(3)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>4', function()
      ui.nav_file(4)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>5', function()
      ui.nav_file(5)
    end, { desc = 'which_key_ignore' })
    vim.keymap.set('n', '<leader>6', function()
      ui.nav_file(6)
    end, { desc = 'which_key_ignore' })
  end,
}
