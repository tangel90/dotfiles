-- Sync clipboard between OS and Neovim.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.opt.clipboard:append 'unnamedplus'
-- Enable break indent
vim.opt.breakindent = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.conceallevel = 2
-- Show which line your cursor is on
vim.opt.cursorline = true

vim.g.OmniSharp_server_use_net6 = 1

-- Hide deprecation warnings
vim.g.deprecation_warnings = false
-- Set filetype to `bigfile` for files larger than 1.5 MB
-- Only vim syntax will be enabled (with the correct filetype)
-- LSP, treesitter and other ft plugins will be disabled.
-- mini.animate will also be disabled.
vim.g.bigfile_size = 1024 * 1024 * 1.5 -- 1.5 MB
-- Show the current document symbols location from Trouble in lualine
vim.g.trouble_lualine = true

-- Set Environment Variables
vim.env.DOTNET_ROOT = os.getenv 'HOME' .. '/.dotnet'
vim.env.PATH = os.getenv 'PATH' .. ':' .. os.getenv 'HOME' .. '/.dotnet:' .. os.getenv 'HOME' .. '/.dotnet/tools'
vim.g.OmniSharp_server_use_net6 = 1

vim.diagnostic.config {
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    format = function(diagnostic)
      local first_line = diagnostic.message:gmatch '[^\n]*'()
      local first_sentence = string.match(first_line, '(.-%. )') or first_line
      local first_lhs = string.match(first_sentence, '(.-): ') or first_sentence
      return first_lhs
    end,
  },
}

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- Set true color support (needs terminal support)
vim.opt.termguicolors = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = 'a'

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

vim.opt.hlsearch = false

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10
