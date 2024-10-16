return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',
    -- see below for full list of optional dependencies 👇
  },
  opts = {
    workspaces = {
      {
        name = 'personal',
        path = '~/obsidian/personal',
      },
      -- {
      --   name = 'work',
      --   path = '~/obsidian/whoishydra',
      -- },
    },

    notes_subdir = 'notes',

    -- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
    -- levels defined by "vim.log.levels.*".
    log_level = vim.log.levels.INFO,

    daily_notes = {
      -- Optional, if you keep daily notes in a separate directory.
      folder = 'notes/dailies',
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = '%Y-%m-%d',
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = '%B %-d, %Y',
      -- Optional, default tags to add to each new daily note created.
      default_tags = { 'daily-notes' },
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = nil,
    },

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
    -- way then set 'mappings = {}'.
    mappings = {
      -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
      ['gf'] = {
        action = function()
          return require('obsidian').util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ['<leader>og'] = {
        action = '<cmd>ObsidianSearch<CR>',
        opts = { buffer = true, desc = '[G]rep in Notes' },
      },
      ['<leader>oo'] = {
        action = '<cmd>ObsidianQuickSwitch<CR>',
        opts = { buffer = true, desc = '[O]pen QuickSwitch' },
      },
      ['<leader>ot'] = {
        action = '<cmd>ObsidianTOC<CR>',
        opts = { buffer = true, desc = '[T]oc' },
      },
      ['<leader>od'] = {
        action = '<cmd>ObsidianDailies<CR>',
        opts = { buffer = true, desc = '[D]ailies' },
      },
      ['<leader>or'] = {
        action = '<cmd>ObsidianRename<CR>',
        opts = { buffer = true, desc = '[R]ename Note' },
      },
      ['<leader>of'] = {
        action = '<cmd>ObsidianTag<CR>',
        opts = { buffer = true, desc = '[F]ind by Tag' },
      },
      ['<leader>ow'] = {
        action = '<cmd>ObsidianWorkspace<CR>',
        opts = { buffer = true, desc = 'Select [W]orkspace' },
      },
      ['<leader>on'] = {
        action = '<cmd>ObsidianNew<CR>',
        opts = { buffer = true, desc = '[N]ew Note' },
      },
      -- Toggle check-boxes.
      ['<leader><leader>'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      -- Smart action depending on context, either follow link or toggle checkbox.
      ['<cr>'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true },
      },
    },
  },
}
