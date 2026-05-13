return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    build = ':UpdateRemotePlugins',
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = 'wezterm.nvim'
      vim.g.molten_auto_open_output = false
      vim.g.molten_output_win_style = 'minimal'
      vim.g.molten_output_win_border = { '', '', '', '' }
      vim.g.molten_output_win_cover_gutter = false
      vim.g.molten_output_crop_border = true
      vim.g.molten_output_show_exec_time = true
      vim.g.molten_output_win_max_height = 30
      vim.g.molten_cover_empty_lines = true
      vim.g.molten_image_location = 'both'
      vim.g.molten_virt_text_output = false
    end,
    -- opts = {},
    config = function()
      vim.keymap.set('n', '<localleader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Molten Initialize' })
      vim.keymap.set('n', '<localleader>mo', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'Molten Run Operator Selection' })
      vim.keymap.set('n', '<localleader>mr', ':MoltenRestart<CR>', { silent = true, desc = 'Molten Restart Kernel' })
      vim.keymap.set('n', '<localleader>mq', ':MoltenDeinit<CR>', { silent = true, desc = 'Molten Deinit (Quit) Instance' })
      vim.keymap.set('n', '<localleader>e', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'Molten Evaluate Line' })
      vim.keymap.set('n', '<localleader>rr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 'Molten re-evaluate cell' })
      vim.keymap.set('v', '<localleader>e', ':<C-u>MoltenEvaluateVisual<CR>gv<Esc>', { silent = true, desc = 'Molten evaluate visual selection' })
      vim.keymap.set('n', '<localleader>md', ':MoltenDelete<CR>', { silent = true, desc = 'Molten Delete Cell' })
      vim.keymap.set('n', '<localleader>j', ':MoltenHideOutput<CR>', { silent = true, desc = 'Molten Hide Output' })
      vim.keymap.set('n', '<localleader>me', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'Molten Show/Enter Output' })
    end,
  },
  {
    'willothy/wezterm.nvim',
    config = true,
  },
}
