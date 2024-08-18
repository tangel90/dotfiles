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
  require 'plugins.custom.neo-tree',

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
  {
    'jiaoshijie/undotree',
    dependencies = 'nvim-lua/plenary.nvim',
    config = true,
    keys = { -- load the plugin only when using it's keybinding:
      { '<leader>u', "<cmd>lua require('undotree').toggle()<cr>", desc = 'Toogle UndoTree' },
    },
  },
  {
    'freddiehaddad/feline.nvim',
    opts = {},
    config = function(_, opts)
      require('feline').setup()
      -- require('feline').winbar.setup() -- to use winbar
      -- require('feline').statuscolumn.setup() -- to use statuscolumn

      -- require('feline').use_theme() -- to use a custom theme
      local line_ok, feline = pcall(require, 'feline')
      if not line_ok then
        return
      end

      local color_palette = {
        fg = '#abb2bf',
        bg = '#1e2024',
        green = '#56949f',
        yellow = '#ea9d34',
        purple = '#907aa9',
        orange = '#d19a66',
        peanut = '#f6d5a4',
        red = '#b4637a',
        aqua = '#61afef',
        darkblue = '#282c34',
        dark_red = '#f75f5f',
      }

      local vi_mode_colors = {
        NORMAL = 'green',
        OP = 'green',
        INSERT = 'yellow',
        VISUAL = 'purple',
        LINES = 'orange',
        BLOCK = 'dark_red',
        REPLACE = 'red',
        COMMAND = 'aqua',
      }

      local c = {
        vim_mode = {
          provider = {
            name = 'vi_mode',
            opts = {
              show_mode_name = true,
              -- padding = "center", -- Uncomment for extra padding.
            },
          },
          hl = function()
            return {
              fg = require('feline.providers.vi_mode').get_mode_color(),
              bg = 'darkblue',
              style = 'bold',
              name = 'NeovimModeHLColor',
            }
          end,
          left_sep = 'block',
          right_sep = 'block',
        },
        gitBranch = {
          provider = 'git_branch',
          hl = {
            fg = 'peanut',
            bg = 'darkblue',
            style = 'bold',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        gitDiffAdded = {
          provider = 'git_diff_added',
          hl = {
            fg = 'green',
            bg = 'darkblue',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        gitDiffRemoved = {
          provider = 'git_diff_removed',
          hl = {
            fg = 'red',
            bg = 'darkblue',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        gitDiffChanged = {
          provider = 'git_diff_changed',
          hl = {
            fg = 'fg',
            bg = 'darkblue',
          },
          left_sep = 'block',
          right_sep = 'right_filled',
        },
        separator = {
          provider = '',
        },
        fileinfo = {
          provider = {
            name = 'file_info',
            opts = {
              type = 'relative-short',
            },
          },
          hl = {
            style = 'bold',
          },
          left_sep = ' ',
          right_sep = ' ',
        },
        diagnostic_errors = {
          provider = 'diagnostic_errors',
          hl = {
            fg = 'red',
          },
        },
        diagnostic_warnings = {
          provider = 'diagnostic_warnings',
          hl = {
            fg = 'yellow',
          },
        },
        diagnostic_hints = {
          provider = 'diagnostic_hints',
          hl = {
            fg = 'aqua',
          },
        },
        diagnostic_info = {
          provider = 'diagnostic_info',
        },
        lsp_client_names = {
          provider = 'lsp_client_names',
          hl = {
            fg = 'purple',
            bg = 'darkblue',
            style = 'bold',
          },
          left_sep = 'left_filled',
          right_sep = 'block',
        },
        file_type = {
          provider = {
            name = 'file_type',
            opts = {
              filetype_icon = true,
              case = 'titlecase',
            },
          },
          hl = {
            fg = 'red',
            bg = 'darkblue',
            style = 'bold',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        file_encoding = {
          provider = 'file_encoding',
          hl = {
            fg = 'orange',
            bg = 'darkblue',
            style = 'italic',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        position = {
          provider = 'position',
          hl = {
            fg = 'green',
            bg = 'darkblue',
            style = 'bold',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        line_percentage = {
          provider = 'line_percentage',
          hl = {
            fg = 'aqua',
            bg = 'darkblue',
            style = 'bold',
          },
          left_sep = 'block',
          right_sep = 'block',
        },
        scroll_bar = {
          provider = 'scroll_bar',
          hl = {
            fg = 'yellow',
            style = 'bold',
          },
        },
      }

      local left = {
        c.vim_mode,
        c.gitBranch,
        c.gitDiffAdded,
        c.gitDiffRemoved,
        c.gitDiffChanged,
        c.separator,
      }

      local middle = {
        c.fileinfo,
        c.diagnostic_errors,
        c.diagnostic_warnings,
        c.diagnostic_info,
        c.diagnostic_hints,
      }

      local right = {
        c.lsp_client_names,
        c.file_type,
        c.file_encoding,
        c.position,
        c.line_percentage,
        c.scroll_bar,
      }

      local components = {
        active = {
          left,
          middle,
          right,
        },
        inactive = {
          left,
          middle,
          right,
        },
      }

      feline.setup {
        components = components,
        theme = color_palette,
        vi_mode_colors = vi_mode_colors,
      }
    end,
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
