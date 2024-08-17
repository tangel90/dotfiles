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
  require 'plugins.custom.molten-nvim',
  require 'plugins.custom.lazygit',
  require 'plugins.custom.rosepine',

  -- Kickstart standard plugins
  require 'plugins.kickstart.nvim-lspconfig',
  require 'plugins.kickstart.telescope',
  require 'plugins.kickstart.nvim-treesitter',
  require 'plugins.kickstart.conform',
  require 'plugins.kickstart.nvim-cmp',
  require 'plugins.kickstart.which-key',
  require 'plugins.kickstart.gitsigns',
  require 'plugins.kickstart.mini',
  require 'plugins.kickstart.autopairs',
  require 'plugins.kickstart.indent_line',

  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.lint',

  -- NOTE: Plugins can be added with a link (or for a github repo: 'owner/repo' link).
  -- NOTE: Plugins can also be added by using a table,
  -- with the first argument being the link and the following
  -- keys can be used to configure plugin behavior/loading/etc.
  --
  -- Use `opts = {}` to force a plugin to be loaded.
  --
  --  This is equivalent to:
  --    require('Comment').setup({})
  --
  --
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },

  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  {
    'sindrets/diffview.nvim',
    opts = {},
  },

  -- The following two comments only work if you have downloaded the kickstart repo, not just copy pasted the
  -- init.lua. If you want these files, they are in the repository, so you can just download them and
  -- place them in the correct locations.

  -- NOTE: Next step on your Neovim journey: Add/Configure additional plugins for Kickstart
  --
  --  Here are some example plugins that I've included in the Kickstart repository.
  --  Uncomment any of the lines below to enable them (you will need to restart nvim).
  --
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
