-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.hl.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})
-- treesitter will not automatically start on branch 'main' anymore
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'python', 'markdown', 'go', 'yaml' },
  callback = function() vim.treesitter.start() end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.chatgpt_history',
  command = "set filetype=markdown"
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.log',
  callback = function()
    vim.opt_local.buftype = 'nofile'
    vim.opt_local.bufhidden = 'wipe'
    vim.opt_local.swapfile = false
    vim.opt_local.modifiable = true
    vim.opt_local.wrap = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.numberwidth = 4
    vim.opt_local.signcolumn = "yes:2"
    vim.opt_local.foldcolumn = "0"
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
    vim.opt_local.foldenable = true
    vim.opt_local.foldlevel = 99
    vim.opt_local.textwidth = 120
    vim.opt.wrapmargin=5
    vim.opt.sidescrolloff=15
    vim.opt.scrolloff=5
    -- vim.opt_local.list = true
    vim.opt_local.linebreak = true
    -- vim.opt_local.showbreak = "↪ "
    -- vim.opt_local.listchars = { tab = "→ ", trail = "·" }
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",  -- or your target language
  callback = function()
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>sf', '<cmd>normal! F"if<Esc>', { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>li', '<cmd>normal! ologger.info(f"")<Esc>', { noremap = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",  -- or your target language
  callback = function()
    -- Map <leader>r to replace '=' with ':=' in the current line
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rd', [[:s/=/:=/g<CR>]], { noremap = true, silent = true })
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*/time_tracking/*.md',
  callback = function()
    require('config.timetracking').setup_keymaps()
  end,
})

local function augroup(name)
  return vim.api.nvim_create_augroup('lazyvim_' .. name, { clear = true })
end

vim.filetype.add {
  pattern = {
    ['.*'] = {
      function(path, buf)
        return vim.bo[buf].filetype ~= 'bigfile' and path and vim.fn.getfsize(path) > vim.g.bigfile_size and 'bigfile' or nil
      end,
    },
  },
}
vim.api.nvim_create_autocmd({ 'FileType' }, {
  group = augroup 'bigfile',
  pattern = 'bigfile',
  callback = function(ev)
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match { buf = ev.buf } or ''
    end)
  end,
})
