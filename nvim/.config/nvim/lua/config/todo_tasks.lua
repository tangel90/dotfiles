-- Task aggregation & archiving across ~/notes (or $NOTES_HOME).
-- Conventions:
--   - [ ] task text #proj/<project> #due/<bucket>
--   Due buckets: overdue, today, this-week, next-week, later, none
--   Status chars treated as "open": space, /, !, ?, >
--   Status chars treated as "closed": x, -

local M = {}

local NOTES_DIR = vim.fn.expand(vim.env.NOTES_HOME or '~/notes')
local DUE_ORDER = { 'overdue', 'today', 'this-week', 'next-week', 'later', 'none' }
local CLOSED = { x = true, ['-'] = true }

local function parse_task(text)
    local status, body = text:match('^%s*%- %[(.)%]%s*(.*)$')
    if not status then return nil end
    local due = body:match('#due/([%w-]+)') or 'none'
    local proj = body:match('#proj/([%w-]+)') or '(no project)'
    return { status = status, body = body, due = due, proj = proj }
end

local function collect_open_tasks()
    local cmd = {
        'rg', '--no-heading', '--line-number', '--glob', '*.md',
        '^\\s*- \\[.\\]', NOTES_DIR,
    }
    local output = vim.fn.systemlist(cmd)
    if vim.v.shell_error ~= 0 then return {} end

    local tasks = {}
    for _, line in ipairs(output) do
        local file, lnum, rest = line:match('^([^:]+):(%d+):(.*)$')
        if file then
            local t = parse_task(rest)
            if t and not CLOSED[t.status] then
                t.file = file
                t.lnum = tonumber(lnum)
                table.insert(tasks, t)
            end
        end
    end
    return tasks
end

function M.view_tasks()
    local tasks = collect_open_tasks()
    local groups = {}
    for _, t in ipairs(tasks) do
        groups[t.due] = groups[t.due] or {}
        groups[t.due][t.proj] = groups[t.due][t.proj] or {}
        table.insert(groups[t.due][t.proj], t)
    end

    local lines, sources = {}, {}
    local function push(line, src)
        table.insert(lines, line)
        sources[#lines] = src
    end

    push('# Tasks  (press <CR> to jump, R to refresh, q to close)')
    push('')

    local seen_any = false
    for _, bucket in ipairs(DUE_ORDER) do
        if groups[bucket] then
            seen_any = true
            push('## ' .. bucket:gsub('-', ' '))
            push('')
            local projs = vim.tbl_keys(groups[bucket])
            table.sort(projs)
            for _, p in ipairs(projs) do
                push('### ' .. p)
                for _, t in ipairs(groups[bucket][p]) do
                    push('- [' .. t.status .. '] ' .. t.body,
                        { file = t.file, lnum = t.lnum })
                end
                push('')
            end
        end
    end

    if not seen_any then push('_no open tasks_') end

    vim.cmd('enew')
    local buf = vim.api.nvim_get_current_buf()
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = 'nofile'
    vim.bo[buf].bufhidden = 'wipe'
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = 'markdown'
    vim.bo[buf].modifiable = false
    pcall(vim.api.nvim_buf_set_name, buf, 'todo://view')

    vim.keymap.set('n', '<CR>', function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local src = sources[row]
        if src then
            vim.cmd('edit ' .. vim.fn.fnameescape(src.file))
            vim.api.nvim_win_set_cursor(0, { src.lnum, 0 })
        end
    end, { buffer = buf, desc = 'Jump to task source' })
    vim.keymap.set('n', 'q', '<cmd>bd<CR>', { buffer = buf, desc = 'Close task view' })
    vim.keymap.set('n', 'R', M.view_tasks, { buffer = buf, desc = 'Refresh task view' })
end

function M.archive_done()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)

    local done_indices, done_content = {}, {}
    local archive_idx = nil
    for i, line in ipairs(lines) do
        if line:match('^%s*%- %[[x%-]%]') then
            table.insert(done_indices, i)
            table.insert(done_content, line)
        end
        if not archive_idx and line:match('^##%s+Archive%s*$') then
            archive_idx = i
        end
    end

    if #done_indices == 0 then
        vim.notify('No done tasks to archive', vim.log.levels.INFO)
        return
    end

    for i = #done_indices, 1, -1 do
        local idx = done_indices[i]
        vim.api.nvim_buf_set_lines(buf, idx - 1, idx, false, {})
        if archive_idx and idx < archive_idx then
            archive_idx = archive_idx - 1
        end
    end

    if not archive_idx then
        local total = vim.api.nvim_buf_line_count(buf)
        vim.api.nvim_buf_set_lines(buf, total, total, false, { '', '## Archive', '' })
        archive_idx = total + 2
    end

    vim.api.nvim_buf_set_lines(buf, archive_idx, archive_idx, false, done_content)
    vim.notify(('Archived %d task%s'):format(#done_indices, #done_indices == 1 and '' or 's'))
end

vim.api.nvim_create_user_command('TodoView', M.view_tasks, { desc = 'Aggregated task view across notes' })
vim.api.nvim_create_user_command('TodoArchive', M.archive_done, { desc = 'Archive done tasks in current buffer' })

vim.keymap.set('n', '<leader>ov', '<cmd>TodoView<CR>', { desc = 'Obsidian: [V]iew all tasks' })
vim.keymap.set('n', '<leader>oA', '<cmd>TodoArchive<CR>', { desc = 'Obsidian: [A]rchive done tasks' })

return M
