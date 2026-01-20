-- define functions for user commands --
--
local enabled = true
function ToggleDiagnosticsVirtualText()
  enabled = not enabled
  vim.diagnostic.config({ virtual_text = enabled })
end

function FetchChtSh(input)
  if input:find '/' then
    local parts = vim.split(input, '/')
    Language = parts[1]
    local query = parts[2]
    Html_query = query:gsub(' ', '+')
  else
    local parts = vim.split(input, ' ')
    Language = parts[1]
    Html_query = table.concat(parts, '+', 2)
  end

  local command = 'curl -s cht.sh/' .. Language .. '/' .. Html_query .. ' | sed -r "s/\\x1B\\[[0-9; ]*[mK]//g"'
  local handle = io.popen(command)

  if handle then
    local result = handle:read '*a'
    handle:close()

    local bufnr = vim.api.nvim_create_buf(false, true)

    -- Set lines in the buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result, '\n'))

    -- Set buffer options
    vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
    vim.api.nvim_set_option_value('modified', false, { buf = bufnr })

    -- Set the filetype
    local filetype = Language
    vim.api.nvim_set_option_value('filetype', filetype, { buf = bufnr })

    -- Create a vertical split
    vim.cmd 'vsplit'

    -- Get the window ID of the newly created split
    local new_win = vim.api.nvim_get_current_win()

    -- Set the buffer only in the new window
    vim.api.nvim_win_set_buf(new_win, bufnr)
  else
    print 'Error reading response.'
  end
end

-- create user commands --

vim.api.nvim_create_user_command('ChtSh', function(opts)
  local query = opts.args ~= '' and opts.args or vim.fn.input 'Enter Query: '
  FetchChtSh(query)
end, { nargs = '?' })

-- create keymaps --

vim.keymap.set('n', '<leader>ch', ':ChtSh<CR>')
