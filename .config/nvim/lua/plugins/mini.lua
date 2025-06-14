return { -- Collection of various small independent plugins/modules
  'echasnovski/mini.nvim',
  config = function()
    -- Better Around/Inside textobjects
    --
    -- Examples:
    --  - va)  - [V]isually select [A]round [)]paren
    --  - yinq - [Y]ank [I]nside [N]ext [']quote
    --  - ci'  - [C]hange [I]nside [']quote
    require('mini.ai').setup { n_lines = 500 }

    -- Add/delete/replace surroundings (brackets, quotes, etc.)
    --
    -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
    -- - sd'   - [S]urround [D]elete [']quotes
    -- - sr)'  - [S]urround [R]eplace [)] [']
    require('mini.surround').setup()

    vim.keymap.set('n', '<leader>ss', ':normal saiw"<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>sS', ':normal saiW"<CR>', { noremap = true, silent = true })

    vim.keymap.set('n', '<leader>s"', ':normal saiw"<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>sq', ':normal saiw"<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>sb', ':normal saiw)<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>s]', ':normal saiw]<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>S"', ':normal saiW"<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>Sq', ':normal saiW"<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>Sb', ':normal saiW)<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>SB', ':normal saiW}<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader>S]', ':normal saiW]<CR>', { noremap = true, silent = true })

    -- Simple and easy statusline.
    --  You could remove this setup call if you don't like it,
    --  and try some other statusline plugin
    -- set use_icons to true if you have a Nerd Font
    -- local statusline = require 'mini.statusline'
    -- statusline.setup { use_icons = vim.g.have_nerd_font }

    -- You can configure sections in the statusline by overriding their
    -- default behavior. For example, here we set the section for
    -- cursor location to LINE:COLUMN
    -- @diagnostic disable-next-line: duplicate-set-field
    -- statusline.section_location = function()
    --   return '%2l:%-2v'
    -- end

    -- ... and there is more!
    --  Check out: https://github.com/echasnovski/mini.nvim
  end,
}
