-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
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

vim.api.nvim_create_autocmd("FileType", {
  pattern = 'markdown',
  callback = function()
    vim.opt_local.wrap = false
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.numberwidth = 4
    vim.opt_local.signcolumn = "yes:2"
    vim.opt_local.foldcolumn = "0"
    vim.opt.wrapmargin=0
    vim.opt.sidescrolloff=15
    vim.opt.scrolloff=5
    vim.opt_local.list = true
    vim.opt_local.linebreak = true
    -- vim.opt_local.showbreak = "↪ "
    vim.opt_local.listchars = { tab = "→ ", trail = "·" }
  end
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",  -- or your target language
  callback = function()
    -- Map <leader>r to replace '=' with ':=' in the current line
    vim.api.nvim_buf_set_keymap(0, 'n', '<leader>rd', [[:s/=/:=/g<CR>]], { noremap = true, silent = true })
  end,
})
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     if vim.fn.argc() == 0 then
--       require("persistence").load({ last = true })
--     end
--   end,
-- })
-- if vim.fn.has 'wsl' == 1 then
--   vim.api.nvim_create_autocmd('TextYankPost', {
--     group = vim.api.nvim_create_augroup('Yank', { clear = true }),
--     callback = function()
--       vim.fn.system('clip.exe', vim.fn.getreg '"')
--     end,
--   })
-- end

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
