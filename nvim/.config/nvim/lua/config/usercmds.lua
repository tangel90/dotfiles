-- define functions for user commands --

vim.api.nvim_create_user_command('FileInfo', function()
  local path = vim.api.nvim_buf_get_name(0)
  local st = vim.uv.fs_stat(path)
  if not st then
    vim.notify('No file on disk: ' .. path, vim.log.levels.WARN)
    return
  end
  local kb = st.size / 1024
  vim.notify(string.format(
    '%s\nsize: %.1f KB\nmodified: %s\ncreated:  %s\nperms: %s',
    vim.fn.fnamemodify(path, ':~'),
    kb,
    os.date('%Y-%m-%d %H:%M:%S', st.mtime.sec),
    os.date('%Y-%m-%d %H:%M:%S', (st.birthtime and st.birthtime.sec) or st.ctime.sec),
    vim.fn.getfperm(path)
  ), vim.log.levels.INFO)
end, { desc = 'Show file info for current buffer' })

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
