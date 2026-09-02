-- Run the current buffer in a tmux pane beside nvim, the way a code-runner
-- extension would: no project config, no .tmux-run, no direnv — just this file
-- and the interpreter it needs.
--
-- <leader>rr is the other half of this: that one runs the *project's* command
-- (.tmux-run / RUN_COMMAND / just / make) in the shared "run" window.
--
-- Output goes to tmux's shared "run" window (the same one prefix+r uses), so
-- prefix+r toggles back to your editor and repeated runs reuse one window
-- instead of stacking panes. `run { split = 'h' }` still opens a side pane for
-- the times you want the output next to the code.

local M = {}

-- filetype -> interpreter. Deliberately small; add as needed.
M.interpreters = {
    python = 'python3',
    sh = 'bash',
    bash = 'bash',
    zsh = 'zsh',
    lua = 'lua',
    javascript = 'node',
    typescript = 'node',
    ruby = 'ruby',
    perl = 'perl',
    r = 'Rscript',
    go = 'go run',
}

--- The shell command to run `file`, or nil if we have no idea how.
--- @param file string absolute path
--- @param filetype string vim filetype
function M.command_for(file, filetype)
    -- A shebang is the file's own answer to this question, so prefer it —
    -- but only if the file can actually be executed.
    local first = (vim.fn.readfile(file, '', 1) or {})[1] or ''
    if first:match '^#!' and vim.fn.executable(file) == 1 then
        return vim.fn.shellescape(file)
    end

    local interp = M.interpreters[filetype]

    -- Python in a uv/poetry project needs the project env, not the system
    -- interpreter, or every third-party import fails.
    if filetype == 'python' then
        local marker = vim.fs.find({ 'uv.lock', 'pyproject.toml' }, {
            upward = true,
            path = vim.fs.dirname(file),
        })[1]
        if marker then
            interp = 'uv run python'
        end
    end

    if not interp then
        return nil
    end
    return interp .. ' ' .. vim.fn.shellescape(file)
end

-- pane id of the last runner pane, so re-running replaces it
local pane = nil

local function pane_alive(id)
    if not id or id == '' then
        return false
    end
    local res = vim.system({ 'tmux', 'list-panes', '-a', '-F', '#{pane_id}' }, { text = true }):wait()
    for line in (res.stdout or ''):gmatch '[^\n]+' do
        if line == id then
            return true
        end
    end
    return false
end

--- Save the buffer and run it.
--- @param opts table|nil { split = 'h'|'v' } to use a side pane instead of the run window
function M.run(opts)
    opts = opts or {}
    local buf = vim.api.nvim_buf_get_name(0)
    if vim.bo.buftype ~= '' or buf == '' then
        vim.notify('code runner: this buffer has no file', vim.log.levels.WARN)
        return
    end
    if not vim.env.TMUX then
        vim.notify('code runner: not inside tmux', vim.log.levels.ERROR)
        return
    end

    vim.cmd 'silent write'

    local cmd = M.command_for(buf, vim.bo.filetype)
    if not cmd then
        vim.notify(("code runner: don't know how to run filetype '%s'"):format(vim.bo.filetype), vim.log.levels.WARN)
        return
    end

    local dir = vim.fs.dirname(buf)

    if not opts.split then
        -- Hand it to tmux-run-command, which owns the run window: reuse, cd,
        -- and the prefix+r toggle. --exec skips its own command resolution, so
        -- a project .tmux-run or RUN_COMMAND does not hijack the interpreter.
        vim.system({ 'tmux-run-command', '--exec', cmd, '--dir', dir }, { text = true }, function(res)
            if res.code ~= 0 then
                vim.schedule(function()
                    vim.notify('code runner: ' .. ((res.stderr ~= '' and res.stderr) or ('exit ' .. res.code)), vim.log.levels.ERROR)
                end)
            end
        end)
        return
    end

    -- Side-pane mode: replace the previous runner pane rather than stacking.
    if pane_alive(pane) then
        vim.system({ 'tmux', 'kill-pane', '-t', pane }):wait()
    end

    local shell_cmd = ('%s; printf "\\n[exit %%s] %s\\n" $?; exec $SHELL'):format(cmd, vim.fs.basename(buf))
    local res = vim.system({
        'tmux',
        'split-window',
        opts.split == 'v' and '-v' or '-h',
        '-l',
        opts.size or '40%',
        '-P',
        '-F',
        '#{pane_id}',
        '-c',
        dir,
        shell_cmd,
    }, { text = true }):wait()

    if res.code ~= 0 then
        vim.notify('code runner: tmux split failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
        return
    end
    pane = vim.trim(res.stdout or '')
end

return M
