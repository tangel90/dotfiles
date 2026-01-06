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

  -- NOTE: The import below can automatically add your own plugins, configuration, etc from `lua/plugins/*.lua`
  --    This is the easiest way to modularize your config.
  --
  --  Uncomment the following line and add your plugins to `lua/plugins/*.lua` to get going.
  --    For additional information, see `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'plugins' },

  {
    'goerz/jupytext.nvim',
    version = '0.2.0',
    opts = {
      jupytext = 'jupytext',
      format = 'markdown',
      update = true,
      sync_patterns = { '*.md', '*.py', '*.jl', '*.R', '*.Rmd', '*.qmd' },
      autosync = true,
      handle_url_schemes = true,
    }, -- see Options
  },
  -- {
  --   'folke/persistence.nvim',
  --   event = 'BufReadPre', -- this will only start session saving when an actual file was opened
  --   opts = {
  --     -- add any custom options here
  --   },
  --   keys = {
  --     { "<leader>qs", function() require("persistence").load() end, desc = "Load session" },
  --     { "<leader>qS", function() require("persistence").select() end, desc = "Select session" },
  --     { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Load last session" },
  --     { "<leader>qd", function() require("persistence").stop() end, desc = "Stop persistence" },
  --   },
  --
  -- },
  'tpope/vim-sleuth', -- Detect tabstop(!!) and shiftwidth automatically
  -- Highlight todo, notes, etc in comments
  { 'folke/todo-comments.nvim', event = 'VimEnter', dependencies = { 'nvim-lua/plenary.nvim' }, opts = { signs = false } },
  -- "gc" to comment visual regions/lines
  -- { 'numToStr/Comment.nvim', opts = {} },
  -- Lua
  -- {
  -- 'git@github.com:tangel90/iris.nvim.git',
  -- opts = {},
  -- config = function(_, opts)
  --   require('iris').setup(opts)
  -- end,
  -- },
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
