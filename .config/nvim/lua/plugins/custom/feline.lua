return {
  'freddiehaddad/feline.nvim',
  opts = {},
  config = function(_, opts)
    -- require('feline').setup()
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
      yellow = '#f6d5a4',
      purple = '#907aa9',
      orange = '#d19a66',
      peanut = '#f6d5a4',
      red = '#b4637a',
      aqua = '#d19a66',
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
          fg = 'peanut',
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
      -- diagnostic_warnings = {
      --   provider = 'diagnostic_warnings',
      --   hl = {
      --     fg = 'yellow',
      --   },
      -- },
      -- diagnostic_hints = {
      --   provider = 'diagnostic_hints',
      --   hl = {
      --     fg = 'aqua',
      --   },
      -- },
      -- diagnostic_info = {
      --   provider = 'diagnostic_info',
      -- },
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
            -- filetype_icon = true,
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
          fg = 'green',
          bg = 'darkblue',
          style = 'bold',
        },
        left_sep = 'block',
        right_sep = 'block',
      },
      -- scroll_bar = {
      --   provider = 'scroll_bar',
      --   hl = {
      --     fg = 'yellow',
      --     style = 'bold',
      --   },
      -- },
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
    }

    local right = {
      c.diagnostic_errors,
      -- c.diagnostic_warnings,
      -- c.diagnostic_hints,
      -- c.diagnostic_info,
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
}
