-- [[ Configure and install plugins ]]
--
--  To check the current status of your plugins, run
--    :Lazy
--
--  You can press `?` in this menu for help. Use `:q` to close the window
--
--  To update plugins you can run
--    :Lazy update
--
-- NOTE: Here is where you install your plugins.
require('lazy').setup({

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/custom/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  -- { import = 'plugins' },
  --
  -- custom plugins
  require 'plugins.custom.oil',
  require 'plugins.custom.harpoon',
  require 'plugins.custom.vim-tmux-navigator',
  require 'plugins.custom.nvim-lightbulb',
  require 'plugins.custom.undotree',
  require 'plugins.custom.rosepine',
  require 'plugins.custom.lsp_signature',
  require 'plugins.custom.feline',
  require 'plugins.custom.obsidian',
  -- require 'plugins.custom.render-markdown',
  -- require 'plugins.custom.molten-nvim',
  -- require 'plugins.custom.lazygit',
  -- require 'plugins.custom.neo-tree',
  -- require 'plugins.custom.toggleterm',

  -- Kickstart standard plugins
  require 'plugins.kickstart.nvim-lspconfig',
  require 'plugins.kickstart.telescope',
  require 'plugins.kickstart.nvim-treesitter',
  require 'plugins.kickstart.conform',
  require 'plugins.kickstart.nvim-cmp',
  require 'plugins.kickstart.nvim-dap',
  require 'plugins.kickstart.which-key',
  require 'plugins.kickstart.gitsigns',
  require 'plugins.kickstart.mini',
  require 'plugins.kickstart.autopairs',
  require 'plugins.kickstart.autotag',
  require 'plugins.kickstart.indent_line',
  -- require 'plugins.kickstart.lint',

  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },
  -- Lua
  -- {
  -- 'git@github.com:tangel90/iris.nvim.git',
  -- opts = {},
  -- config = function(_, opts)
  --   require('iris').setup(opts)
  -- end,
  -- },
  {
    'folke/zen-mode.nvim',
    opts = {
      window = {
        backdrop = 0.95, -- shade the backdrop of the Zen window. Set to 1 to keep the same as Normal
        -- height and width can be:
        -- * an absolute number of cells when > 1
        -- * a percentage of the width / height of the editor when <= 1
        -- * a function that returns the width or the height
        width = 0.70, -- width of the Zen window
        height = 1, -- height of the Zen window
        -- by default, no options are changed for the Zen window
        -- uncomment any of the options below, or add other vim.wo options you want to apply
        options = {
          -- signcolumn = "no", -- disable signcolumn
          -- number = false, -- disable number column
          -- relativenumber = false, -- disable relative numbers
          -- cursorline = false, -- disable cursorline
          -- cursorcolumn = false, -- disable cursor column
          -- foldcolumn = "0", -- disable fold column
          -- list = false, -- disable whitespace characters
        },
      },
    },
  },
  {
    'sindrets/diffview.nvim',
    opts = {},
  },
  {
    'OmniSharp/omnisharp-vim',
    config = function() end,
  },
  { 'Hoffs/omnisharp-extended-lsp.nvim', lazy = true, opts = nil }, -- necessary to get LSP to work with external files
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})
