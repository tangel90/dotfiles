-- Run the current buffer in a tmux pane beside nvim, the way a code-runner
-- extension would: no project config, no .tmux-run, no direnv — just this file
-- and the interpreter it needs.
--
-- <leader>rr is the other half of this: that one runs the *project's* command
-- (.tmux-run / RUN_COMMAND / just / make) in the shared "run" window.
--
-- The pane is replaced on each run rather than stacking splits, and it drops
-- into a shell afterwards so the output stays readable and you can re-run with
-- `!!` or poke around in the same directory.

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

--- Save the buffer and run it in a fresh tmux pane.
--- @param opts table|nil { split = 'h'|'v', size = string }
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

    if pane_alive(pane) then
        vim.system({ 'tmux', 'kill-pane', '-t', pane }):wait()
    end

    -- Report the exit status, then hand the pane to a shell so it stays open.
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
        vim.fs.dirname(buf),
        shell_cmd,
    }, { text = true }):wait()

    if res.code ~= 0 then
        vim.notify('code runner: tmux split failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
        return
    end
    pane = vim.trim(res.stdout or '')
end

return M
