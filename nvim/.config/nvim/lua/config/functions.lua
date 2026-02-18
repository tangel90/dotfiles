open_url = function(url)
  local open_cmd = 'xdg-open'
  os.execute(open_cmd .. ' ' .. url)
end


-- <Tab> will only switch between two files
ToggleBuffers = function()
    local current = vim.fn.bufnr '%'
    local last = vim.fn.bufnr '#'
    if last ~= -1 and last ~= current then
        vim.cmd('buffer ' .. last)
    end
end
