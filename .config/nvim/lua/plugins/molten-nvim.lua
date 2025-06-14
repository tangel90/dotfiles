return {
  {
    'benlubas/molten-nvim',
    version = '^1.0.0', -- use version <2.0.0 to avoid breaking changes
    dependencies = { '3rd/image.nvim' },
    build = ':UpdateRemotePlugins',
    init = function()
      -- these are examples, not defaults. Please see the readme
      vim.g.molten_image_provider = 'image.nvim'
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
    -- see the image.nvim readme for more information about configuring this plugin
    '3rd/image.nvim',
    opts = {
      backend = 'kitty', -- whatever backend you would like to use
      processor = 'magick_cli', -- or "magick_cli"
      integrations = {
        html = {
          enabled = false,
        },
      },
      rocks = {
        hererocks = true,
      },
      max_width = 100,
      max_height = 12,
      max_height_window_percentage = math.huge,
      max_width_window_percentage = math.huge,
      window_overlap_clear_enabled = true, -- toggles images when windows are overlappe
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
      editor_only_render_when_focused = false, -- auto show/hide images when the editor gains/looses focu
      tmux_show_only_in_active_window = true, -- auto show/hide images in the correct Tmux window (needs visual-activity off)
      hijack_file_patterns = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.avif' }, -- render image files as images when opened
    },
  },
}
