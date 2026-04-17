local M = {}

local tt_dir = vim.fn.expand('~/notes/management/time_tracking')

local function now_hhmm()
  return os.date('%H:%M')
end

local function today_heading()
  return '## ' .. os.date('%A %Y-%m-%d')
end

local function week_filename()
  return os.date('%G-W%V') .. '.md'
end

local function week_heading()
  return '# ' .. os.date('%G-W%V')
end

--- Find the line number of today's heading in the current buffer, or nil
local function find_today_line()
  local heading = today_heading()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i, line in ipairs(lines) do
    if line == heading then
      return i -- 1-indexed
    end
  end
  return nil
end

--- Find the last line of today's section (before the next ## heading or EOF)
local function find_today_section_end()
  local start = find_today_line()
  if not start then return nil end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for i = start + 1, #lines do
    if lines[i]:match('^## ') then
      return i - 1
    end
  end
  return #lines
end

--- Parse HH:MM string into total minutes
local function parse_time(s)
  local h, m = s:match('(%d%d):(%d%d)')
  if not h then return nil end
  return tonumber(h) * 60 + tonumber(m)
end

--- Format minutes as Xh YYm
local function fmt_duration(mins)
  if mins < 0 then mins = 0 end
  return string.format('%dh %02dm', math.floor(mins / 60), mins % 60)
end

function M.open_week()
  local filepath = tt_dir .. '/' .. week_filename()
  vim.cmd('edit ' .. vim.fn.fnameescape(filepath))
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  if #lines == 0 or (#lines == 1 and lines[1] == '') then
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { week_heading(), '' })
  end
end

function M.clock_in()
  local today_line = find_today_line()
  if today_line then
    vim.notify('Already clocked in today', vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local insert_at = #lines
  -- Append after last content line
  local new_lines = { '', today_heading(), '- Start: ' .. now_hhmm() }
  vim.api.nvim_buf_set_lines(0, insert_at, insert_at, false, new_lines)
  vim.api.nvim_win_set_cursor(0, { insert_at + #new_lines, 0 })
  vim.cmd('noautocmd write')
end

function M.clock_out()
  local section_end = find_today_section_end()
  if not section_end then
    vim.notify('No clock-in found for today', vim.log.levels.WARN)
    return
  end
  local new_lines = { '- End: ' .. now_hhmm() }
  vim.api.nvim_buf_set_lines(0, section_end, section_end, false, new_lines)
  vim.cmd('noautocmd write')
  M.calculate()
end

function M.break_start()
  local section_end = find_today_section_end()
  if not section_end then
    vim.notify('No clock-in found for today', vim.log.levels.WARN)
    return
  end
  local new_lines = { '- Break: ' .. now_hhmm() .. ' - ' }
  vim.api.nvim_buf_set_lines(0, section_end, section_end, false, new_lines)
  vim.api.nvim_win_set_cursor(0, { section_end + 1, 0 })
  vim.cmd('noautocmd write')
end

function M.break_end()
  local start = find_today_line()
  local section_end = find_today_section_end()
  if not start or not section_end then
    vim.notify('No clock-in found for today', vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, start - 1, section_end, false)
  -- Find last open break line (ends with "- ")
  for i = #lines, 1, -1 do
    if lines[i]:match('^%- Break: %d%d:%d%d %- $') then
      local line_nr = start - 1 + i - 1 -- 0-indexed
      local updated = lines[i] .. now_hhmm()
      vim.api.nvim_buf_set_lines(0, line_nr, line_nr + 1, false, { updated })
      vim.cmd('noautocmd write')
      return
    end
  end
  vim.notify('No open break found', vim.log.levels.WARN)
end

function M.calculate()
  local start = find_today_line()
  local section_end = find_today_section_end()
  if not start or not section_end then
    vim.notify('No clock-in found for today', vim.log.levels.WARN)
    return
  end
  local lines = vim.api.nvim_buf_get_lines(0, start - 1, section_end, false)

  local start_time, end_time
  local total_break = 0

  for _, line in ipairs(lines) do
    local st = line:match('^%- Start: (%d%d:%d%d)')
    if st then start_time = parse_time(st) end

    local et = line:match('^%- End: (%d%d:%d%d)')
    if et then end_time = parse_time(et) end

    local bs, be = line:match('^%- Break: (%d%d:%d%d) %- (%d%d:%d%d)')
    if bs and be then
      total_break = total_break + (parse_time(be) - parse_time(bs))
    end
  end

  if not start_time then
    vim.notify('No start time found', vim.log.levels.WARN)
    return
  end

  local now = end_time or parse_time(now_hhmm())
  local gross = now - start_time
  local net = gross - total_break

  local summary = '> Work: ' .. fmt_duration(gross) .. ' | Breaks: ' .. fmt_duration(total_break) .. ' | Net: ' .. fmt_duration(net)

  -- Check if summary line already exists and replace it, otherwise append
  local summary_line = nil
  for i = #lines, 1, -1 do
    if lines[i]:match('^> Work:') then
      summary_line = start - 1 + i - 1 -- 0-indexed
      break
    end
  end

  if summary_line then
    vim.api.nvim_buf_set_lines(0, summary_line, summary_line + 1, false, { summary })
  else
    vim.api.nvim_buf_set_lines(0, section_end, section_end, false, { summary })
  end
  vim.cmd('noautocmd write')
end

function M.setup_keymaps()
  local opts = function(desc) return { buffer = 0, desc = desc } end
  vim.keymap.set('n', '<leader>ti', M.clock_in, opts('Time: clock in'))
  vim.keymap.set('n', '<leader>to', M.clock_out, opts('Time: clock out'))
  vim.keymap.set('n', '<leader>tb', M.break_start, opts('Time: break start'))
  vim.keymap.set('n', '<leader>te', M.break_end, opts('Time: break end'))
  vim.keymap.set('n', '<leader>tm', M.calculate, opts('Time: calculate'))
end

return M
