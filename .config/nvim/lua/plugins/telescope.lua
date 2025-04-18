return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  event = 'VimEnter',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  config = function()
    -- Telescope is a fuzzy finder that comes with a lot of different things that
    -- it can fuzzy find! It's more than just a "file finder", it can search
    -- many different aspects of Neovim, your workspace, LSP, and more!
    --
    -- The easiest way to use Telescope, is to start by doing something like:
    --  :Telescope help_tags
    --
    -- After running this command, a window will open up and you're able to
    -- type in the prompt window. You'll see a list of `help_tags` options and
    -- a corresponding preview of the help.
    --
    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      pickers = {
        live_grep = {
          additional_args = function(opts)
            return { '--hidden' }
          end,
        },
      },
      defaults = {
        vimgrep_arguments = {
          'rg',
          '--color=never',
          '--no-heading',
          '--with-filename',
          '--line-number',
          '--column',
          '--smart-case',
          '-u', -- thats the new thing
        },
        --   mappings = {
        --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
        --   },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension, 'harpoon')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = '[F]ind [H]elp' })
    vim.keymap.set('n', '<leader>fk', builtin.keymaps, { desc = '[F]ind [K]eymaps' })
    vim.keymap.set('n', '<leader>fs', builtin.builtin, { desc = '[F]ind [S]elect Telescope' })
    vim.keymap.set('n', '<leader>fw', builtin.grep_string, { desc = '[F]ind Current [W]ord' })
    vim.keymap.set('n', '<leader>fp', builtin.git_files, { desc = '[F]ind [G]it Project Files' })
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = '[F]ind by [G]rep' })
    vim.keymap.set('n', '<leader>df', builtin.diagnostics, { desc = 'List [D]iagnostics' })
    -- vim.keymap.set('n', '<leader>fr', builtin.resume, { desc = '[F]ind [R]esume' })
    vim.keymap.set('n', '<leader>f.', builtin.oldfiles, { desc = '[F]ind Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>ff', function()
      builtin.find_files { find_command = { 'rg', '--no-ignore', '--hidden', '--files', '-g', '!node_modules', '-g', '!__pycache__', '-g', '!.venv' } }
    end, { desc = '[F]ind [F]iles' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 3,
        previewer = true,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>f/', function()
      builtin.live_grep {
        find_command = { 'rg', '--hidden', '--glob', '!.git/', '--glob', '!__pycache__/', '--glob', '!.venv/', '--glob', '!node_modules/' },
        grep_open_files = false,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[F]ind [/] in Open Files' })

    vim.keymap.set('n', '<leader>fd', function()
      builtin.find_files { cwd = '~/dotfiles', find_command = { 'rg', '--ignore', '--hidden', '--files' }, prompt_prefix = '🔍 ' }
    end, { desc = '[F]ind [D]otfiles' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>fn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[F]ind Files in Neo[v]im Configuration' })

    vim.keymap.set('n', '<leader>ft', function()
      local notes_home = os.getenv 'NOTES_HOME'
      if not notes_home then
        print 'Please set $NOTES_HOME environment variable.'
      else
        builtin.find_files { cwd = notes_home }
      end
    end, { desc = '[F]ind in Notes' })

    vim.keymap.set('n', '<leader>f~', function()
      builtin.find_files { cwd = '~/', find_command = { 'rg', '--hidden', '--files' }, prompt_prefix = '🔍 ' }
    end, { desc = '[F]ind Files in Home Directory' })

    vim.keymap.set('n', '<leader>fo', function()
      local projects_home = os.getenv 'PROJECTS_HOME'
      if not projects_home then
        print 'Please set $PROJECTS_HOME environment variable.'
      else
        builtin.find_files { cwd = projects_home, find_command = { 'rg', '--ignore', '--hidden', '--files' }, prompt_prefix = '🔍 ' }
      end
    end, { desc = '[F]ind in Projects' })

    vim.keymap.set('n', '<leader>fm', function()
      builtin.find_files { cwd = '/mnt/d/clinical_data_repository/modules/' }
    end, { desc = '[F]ind in CDR [M]odules' })
  end,
}
