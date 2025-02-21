return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    -- dependencies = { 'wezterm.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = 'wezterm'
      vim.g.molten_output_win_max_height = 20
    end,
    opts = {},
    config = function()
      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = '[I]nitialize the plugin' })
      vim.keymap.set('n', '<localleader>ro', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'run operator selection' })
      vim.keymap.set('n', '<localleader>re', ':MoltenEvaluateLine<CR>', { silent = true, desc = '[E]valuate Line' })
      vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 're-evaluate cell' })
      vim.keymap.set('v', '<localleader>r', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'evaluate visual selection' })
      vim.keymap.set('n', '<localleader>rd', ':MoltenDelete<CR>', { silent = true, desc = 'molten delete cell' })
      vim.keymap.set('n', '<localleader>oh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
      vim.keymap.set('n', '<localleader>os', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
    end,
  },
}
