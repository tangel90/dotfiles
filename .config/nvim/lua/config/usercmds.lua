-- define functions for user commands --

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

    local bufnr = vim.api.nvim_create_buf(false, true) -- Create a new buffer(listed, scratch)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, vim.split(result, '\n'))
    vim.api.nvim_set_option_value('readonly', true, { buf = bufnr })
    vim.api.nvim_set_option_value('modified', false, { buf = bufnr })

    local filetype = Language

    vim.api.nvim_set_option_value('filetype', filetype, { buf = bufnr })
    vim.api.nvim_win_set_buf(0, bufnr)
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
