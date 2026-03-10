-- define functions for user commands --
--
local enabled = true
function ToggleDiagnosticsVirtualText()
  enabled = not enabled
  vim.diagnostic.config({ virtual_text = enabled })
end

-- create user commands --

vim.api.nvim_create_user_command('ChtSh', function(opts)
  local query = opts.args ~= '' and opts.args or vim.fn.input 'Enter Query: '
  FetchChtSh(query)
end, { nargs = '?' })

-- create keymaps --

vim.keymap.set('n', '<leader>ch', ':ChtSh<CR>')
