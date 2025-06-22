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

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.chatgpt_history',
  command = 'set filetype=markdown',
})

-- if vim.fn.has 'wsl' == 1 then
--   vim.api.nvim_create_autocmd('TextYankPost', {
--     group = vim.api.nvim_create_augroup('Yank', { clear = true }),
--     callback = function()
--       vim.fn.system('clip.exe', vim.fn.getreg '"')
--     end,
--   })
-- end
--
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
