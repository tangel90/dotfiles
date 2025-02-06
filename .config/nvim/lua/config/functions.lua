open_url = function(url)
  local open_cmd = 'xdg-open'
  os.execute(open_cmd .. ' ' .. url)
end
