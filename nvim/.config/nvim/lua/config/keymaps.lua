local map = vim.keymap.set
local function run_in_term(cmd, opts)
    opts = opts or {}
    vim.cmd('tabnew | term ' .. cmd)
    vim.cmd 'startinsert'
    if opts.auto_close then
        local buf = vim.api.nvim_get_current_buf()
        vim.api.nvim_create_autocmd('TermClose', {
            buffer = buf,
            once = true,
            callback = function()
                local code = (vim.v.event and vim.v.event.status) or 0
                vim.schedule(function()
                    if code ~= 0 then
                        vim.notify('command exited ' .. code .. ' — leaving terminal open', vim.log.levels.WARN)
                        return
                    end
                    if vim.api.nvim_buf_is_valid(buf) then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end)
            end,
        })
    end
end

--- markdown keymaps ---

map('n', '<leader>id', '<cmd>r!date +\\%b-\\%d<CR>', { desc = "Insert today's date" })

-- Snowflake / Postgres runners: scoped to .sql files under ~/data or ~/dev
local sql_runner_dirs = {
    vim.fn.expand '~' .. '/data/',
    vim.fn.expand '~' .. '/dev/',
}

local function in_sql_runner_dir(path)
    for _, dir in ipairs(sql_runner_dirs) do
        if path:sub(1, #dir) == dir then
            return true
        end
    end
    return false
end

-- Ask the DB to EXPLAIN the buffer's SQL before running. Returns true if the
-- query is structurally valid (or the user chooses to proceed despite an error).
-- Uses `psql` for postgres-flavoured files; snow explain for snowflake.
local function explain_check_psql(sql)
    local clean = sql:gsub(';%s*$', ''):gsub('%s*$', '')
    local out = vim.fn.systemlist {
        'psql',
        '-q',
        '-v',
        'ON_ERROR_STOP=1',
        '-P',
        'pager=off',
        '-c',
        'EXPLAIN ' .. clean,
    }
    if vim.v.shell_error == 0 then
        return true
    end
    local msg = table.concat(out, '\n'):gsub('\n*$', '')
    local ans = vim.fn.confirm('Query rejected by DB:\n' .. msg .. '\n\nRun anyway?', '&Yes\n&No', 2)
    return ans == 1
end

local function explain_check_snow(path)
    local out = vim.fn.systemlist {
        vim.fn.expand '~/.local/bin/snow',
        'sql',
        '--format',
        'json',
        '-q',
        'EXPLAIN USING TEXT SELECT 1', -- warm check that snow is reachable
    }
    -- snow doesn't support EXPLAIN on arbitrary SQL files directly;
    -- fall through without blocking if we can't validate.
    return true
end

local function buf_sql(buf)
    return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
end

-- Linewise text of the active visual selection. Must be called while still in
-- visual mode ('v is only set on exit), so it reads the range first and then
-- leaves the mode itself. Linewise is enough for SQL.
local function visual_sql(buf)
    local s, e = vim.fn.line 'v', vim.fn.line '.'
    if s > e then
        s, e = e, s
    end
    vim.api.nvim_feedkeys(vim.keycode '<Esc>', 'nx', false)
    return table.concat(vim.api.nvim_buf_get_lines(buf, s - 1, e, false), '\n')
end

-- The single line under the cursor. For one-liner probes (SELECT count(*) …,
-- SHOW TABLES) where sending the whole buffer would run every other statement
-- in it too.
local function line_sql(buf)
    local lnum = vim.fn.line '.'
    return vim.api.nvim_buf_get_lines(buf, lnum - 1, lnum, false)[1] or ''
end

-- Descriptive basename for query-result scratch files: reuses nvim's
-- per-session random tempdir (still unique / auto-cleaned) but names the
-- file after the source .sql file + a timestamp, so it's meaningful if it
-- later gets saved (e.g. via VisiData's save prompt) instead of a bare
-- tempname() counter like "0.jsonl".
local function query_out_path(sql_path, ext)
    local dir = vim.fn.fnamemodify(vim.fn.tempname(), ':h')
    local stem = vim.fn.fnamemodify(sql_path, ':t:r')
    return string.format('%s/%s_%s.%s', dir, stem, os.date '%Y%m%dT%H%M%S', ext)
end

-- Persistent snowflake session: a reader process (started with <leader>rQ, or by
-- hand) sits on a FIFO and executes whatever is written to it, so session state
-- (USE WAREHOUSE, temp tables, …) survives between sends — unlike <leader>rs,
-- which is one `snow sql -f` invocation per run.
-- Override the paths/commands with vim.g.snow_session_fifo / vim.g.snow_session_cmd.
local function snow_fifo()
    return vim.g.snow_session_fifo or '/tmp/snow_session_tst.fifo'
end

-- Queries under ~/data/snowflake/database_explorer are env-neutral: they write
-- {{ENV}}_RV.CORE.X so one tree serves dev/tst/prd, with direnv supplying ENV
-- per directory. snow-parquet does this substitution itself for `-f` runs, but
-- the FIFO session receives raw buffer text, so it has to happen here too.
-- Returns nil (and notifies) when ENV is missing rather than sending SQL that
-- would query `_RV.CORE.X` or, worse, the wrong environment.
-- Where ENV comes from, in order: the environment nvim inherited (direnv, when
-- nvim was launched from inside an env dir), an explicit :SnowEnv override, then
-- the nearest .envrc above cwd.
--
-- The buffer path is deliberately not a source. The explorer tree is one shared
-- directory symlinked into dev/tst/prd, and nvim resolves the symlink when
-- opening a file, so a buffer opened via tst/ reports the shared path and never
-- names an environment.
local function envrc_env()
    local found = vim.fs.find('.envrc', { upward = true, path = vim.fn.getcwd(), type = 'file' })[1]
    if not found then
        return nil
    end
    for line in io.lines(found) do
        local v = line:match '^%s*export%s+ENV=([%w_]+)'
        if v then
            return v
        end
    end
    return nil
end

local function snow_env()
    if vim.env.ENV and vim.env.ENV ~= '' then
        return vim.env.ENV
    end
    if vim.g.snow_env and vim.g.snow_env ~= '' then
        return vim.g.snow_env
    end
    return envrc_env()
end

vim.api.nvim_create_user_command('SnowEnv', function(o)
    if o.args == '' then
        vim.notify('snow env: ' .. tostring(snow_env()), vim.log.levels.INFO)
        return
    end
    vim.g.snow_env = o.args:upper()
    -- A running FIFO session keeps whatever connection it was started with, so
    -- switching env here only redirects one-shot runs unless it is restarted.
    vim.notify(('snow env set to %s (restart the FIFO session to move it too)'):format(vim.g.snow_env), vim.log.levels.INFO)
end, {
    nargs = '?',
    complete = function()
        return { 'dev', 'tst', 'prd' }
    end,
    desc = 'show or override the environment {{ENV}} expands to',
})

local function expand_env(sql)
    if not sql:find('{{ENV}}', 1, true) then
        return sql
    end
    local env = snow_env()
    if not env or env == '' then
        vim.notify('SQL contains {{ENV}} but no environment is known — run :SnowEnv tst, or start nvim from an env dir', vim.log.levels.ERROR)
        return nil
    end
    -- braces are not magic in lua patterns, so a plain gsub is fine here
    return (sql:gsub('{{ENV}}', env:upper()))
end

-- Writing to a FIFO blocks until a reader shows up, so this must never run on
-- nvim's main loop: vim.system pipes the SQL in via stdin asynchronously.
local function snow_session_send(sql, label)
    local fifo = snow_fifo()
    if vim.fn.getftype(fifo) ~= 'fifo' then
        vim.notify('no snow session FIFO at ' .. fifo .. ' — start one with <leader>rQ', vim.log.levels.ERROR)
        return
    end
    sql = expand_env(sql)
    if not sql then
        return
    end
    if not sql:match '\n$' then
        sql = sql .. '\n'
    end
    vim.system({ 'sh', '-c', 'cat > ' .. vim.fn.shellescape(fifo) }, { stdin = sql }, function(res)
        if res.code ~= 0 then
            vim.schedule(function()
                vim.notify('snow session write failed: ' .. (res.stderr or ('exit ' .. res.code)), vim.log.levels.ERROR)
            end)
        end
    end)
    vim.notify('sent ' .. label .. ' → snow session', vim.log.levels.INFO)
end

-- Create the FIFO (if missing) and run the reader in a new tmux window.
local function snow_session_start()
    if not vim.env.TMUX then
        vim.notify('not inside tmux — cannot host the snow session', vim.log.levels.ERROR)
        return
    end
    local fifo = snow_fifo()
    if vim.fn.getftype(fifo) ~= 'fifo' then
        vim.fn.system { 'mkfifo', fifo }
        if vim.v.shell_error ~= 0 then
            vim.notify('mkfifo ' .. fifo .. ' failed', vim.log.levels.ERROR)
            return
        end
    end
    -- tail -f keeps the write end open, so the reader doesn't exit on EOF
    -- after each send.
    local tmpl = vim.g.snow_session_cmd or 'tail -f %s | snow sql -i'
    local cmd = tmpl:format(vim.fn.shellescape(fifo))
    vim.system({ 'tmux', 'new-window', '-d', '-n', 'snow', cmd }, { text = true }, function(res)
        vim.schedule(function()
            if res.code ~= 0 then
                vim.notify('failed to start snow session: ' .. (res.stderr or ''), vim.log.levels.ERROR)
            else
                vim.notify('snow session listening on ' .. fifo, vim.log.levels.INFO)
            end
        end)
    end)
end

-- Run a shell pipeline that writes query results to `out_file`, then — only on
-- success — open visidata on it in a new tmux window. The query itself runs as
-- an async background job in nvim (no terminal buffer); errors are surfaced via
-- vim.notify. Requires running inside tmux.
local function run_to_visidata_tmux(shell_cmd, out_file, label, cwd)
    if not vim.env.TMUX then
        vim.notify('not inside tmux — cannot open external visidata pane', vim.log.levels.ERROR)
        return
    end
    vim.notify('running ' .. label .. ' …', vim.log.levels.INFO)
    vim.system({ 'sh', '-c', shell_cmd }, { text = true }, function(res)
        vim.schedule(function()
            if res.code ~= 0 then
                local err = (res.stderr ~= '' and res.stderr) or res.stdout or ('exit ' .. res.code)
                vim.notify(label .. ' failed:\n' .. err, vim.log.levels.ERROR)
                return
            end
            -- New tmux window named "vd", with cwd set to the target dir,
            -- running visidata on the result file. Create it DETACHED (-d) so
            -- focus doesn't switch mid-query — any buffered keystrokes stay in
            -- nvim instead of leaking into visidata — then select it once it's
            -- spawned. -P -F prints the window id so we select exactly it.
            local tmux_cmd = { 'tmux', 'new-window', '-d', '-P', '-F', '#{window_id}', '-n', 'vd' }
            if cwd then
                vim.fn.mkdir(cwd, 'p') -- ensure the dir exists
                table.insert(tmux_cmd, '-c')
                table.insert(tmux_cmd, cwd)
            end
            table.insert(tmux_cmd, 'visidata ' .. vim.fn.shellescape(out_file))
            vim.system(tmux_cmd, { text = true }, function(win)
                local win_id = (win.stdout or ''):gsub('%s+$', '')
                if win.code == 0 and win_id ~= '' then
                    -- brief settle, then switch to the fully-initialised window
                    vim.system { 'tmux', 'select-window', '-t', win_id }
                end
            end)
            vim.notify(label .. ' → opened in tmux window', vim.log.levels.INFO)
        end)
    end)
end

-- Wrap a "query → CSV on stdout" command so the result lands as parquet, and
-- return the shell pipeline plus the file visidata should open.
--
-- Why bother: visidata's text loaders (csv/json) type every column as anytype,
-- so SQL casts are lost and dates/numbers are re-parsed from strings on every
-- cell access. Parquet carries the types (arrow_to_vdtype), and duckdb's
-- read_csv infers them from the CSV in one pass. Measured on 200k rows x 10
-- cols: file 22M → 4.2M, vd load 0.57s → 0.33s, and with date/float columns
-- actually typed, a full scan of 3 columns drops 10.9s → 1.4s and sort-by-date
-- 5.7s → 0.8s. The conversion itself costs ~0.3s.
--
-- duckdb only needs its bundled CSV reader here (no extension autoload, unlike
-- read_json_auto). If duckdb is missing the command fails loudly via notify.
local function csv_to_parquet(cmd_to_csv, csv_file)
    local parquet = csv_file:gsub('%.csv$', '') .. '.parquet'
    -- SQL string literals: single quotes, doubled to escape. tempnames never
    -- contain quotes, but keep it correct anyway.
    local function sql_str(s)
        return "'" .. s:gsub("'", "''") .. "'"
    end
    local sql = string.format('COPY (FROM read_csv(%s)) TO %s (FORMAT parquet)', sql_str(csv_file), sql_str(parquet))
    return string.format('%s && duckdb -c %s', cmd_to_csv, vim.fn.shellescape(sql)), parquet
end

-- Same as run_to_visidata_tmux, but on success opens the result file in a new
-- vim buffer (vsplit) instead of an external visidata pane.
local function run_to_vim_buffer(shell_cmd, out_file, label)
    vim.notify('running ' .. label .. ' …', vim.log.levels.INFO)
    vim.system({ 'sh', '-c', shell_cmd }, { text = true }, function(res)
        vim.schedule(function()
            if res.code ~= 0 then
                local err = (res.stderr ~= '' and res.stderr) or res.stdout or ('exit ' .. res.code)
                vim.notify(label .. ' failed:\n' .. err, vim.log.levels.ERROR)
                return
            end
            vim.cmd('edit ' .. vim.fn.fnameescape(out_file))
            vim.notify(label .. ' → opened in buffer', vim.log.levels.INFO)
        end)
    end)
end

vim.api.nvim_create_autocmd('FileType', {
    pattern = 'sql',
    callback = function(args)
        local path = vim.api.nvim_buf_get_name(args.buf)
        if not in_sql_runner_dir(path) then
            return
        end
        local bufopt = { buffer = args.buf }

        vim.keymap.set('n', '<leader>rs', function()
            -- snow EXPLAIN is not reliably available; skip pre-flight for snow.
            -- snow-parquet instead of `snow sql`: the CLI can only print text, so
            -- the old json/csv route made Snowflake's arrow result set into
            -- strings just for something downstream to parse back. snow-parquet
            -- fetches the arrow batches straight from the connector and writes
            -- parquet — no text hop, and warehouse types (TIMESTAMP, NUMBER)
            -- reach visidata intact. No duckdb pass needed here.
            local out = query_out_path(path, 'parquet')
            -- snow-parquet expands {{ENV}} itself, but it only sees the
            -- environment nvim hands it — which is empty unless nvim happened to
            -- be started inside an env dir. Pass the env this buffer resolved to,
            -- and the matching connection, so the database and the credentials
            -- agree instead of silently falling back to config.toml's default.
            local env = snow_env()
            if not env then
                vim.notify('no environment known for {{ENV}} — run :SnowEnv tst, or start nvim from an env dir', vim.log.levels.ERROR)
                return
            end
            local cmd = string.format(
                'ENV=%s SNOWFLAKE_DEFAULT_CONNECTION_NAME=%s snow-parquet -f %s -o %s',
                vim.fn.shellescape(env:upper()),
                vim.fn.shellescape(env:lower()),
                vim.fn.shellescape(path),
                vim.fn.shellescape(out)
            )
            run_to_visidata_tmux(cmd, out, 'snow query', vim.fn.expand '~/data/snowflake/')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow → arrow → parquet → visidata (tmux)' }))

        -- Feed the long-lived session instead of a one-shot run.
        vim.keymap.set('n', '<leader>rq', function()
            snow_session_send(buf_sql(args.buf), 'buffer')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow session ← buffer' }))

        -- Run `sql` on the warm snow session and open the result in visidata.
        -- The session writes the CSV itself (out/format header) and touches
        -- <out>.done when finished, so nvim just waits on that marker.
        local function snow_session_to_visidata(sql, label)
            local out = query_out_path(path, 'csv')
            local done = out .. '.done'
            vim.fn.delete(done)
            snow_session_send(('-- out: %s\n-- format: csv\n%s'):format(out, sql), label .. ' → visidata')
            -- Block until the session signals completion; non-zero exit surfaces via notify.
            local wait = ('for i in $(seq 1 6000); do [ -f %s ] && break; sleep 0.1; done; grep -q "^ok$" %s'):format(
                vim.fn.shellescape(done),
                vim.fn.shellescape(done)
            )
            run_to_visidata_tmux(wait, out, 'snow session', vim.fn.expand '~/data/snowflake/')
        end

        vim.keymap.set('n', '<leader>rv', function()
            snow_session_to_visidata(line_sql(args.buf), 'line')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow session ← line -> visidata (warm)' }))

        vim.keymap.set('n', '<leader>rV', function()
            snow_session_to_visidata(buf_sql(args.buf), 'buffer')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow session ← buffer -> visidata (warm)' }))

        vim.keymap.set('x', '<leader>rv', function()
            snow_session_to_visidata(visual_sql(args.buf), 'selection')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow session ← selection -> visidata (warm)' }))

        vim.keymap.set('x', '<leader>rq', function()
            snow_session_send(visual_sql(args.buf), 'selection')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow session ← selection' }))

        vim.keymap.set(
            'n',
            '<leader>rQ',
            snow_session_start,
            vim.tbl_extend('force', bufopt, { desc = 'start snow session (tmux + FIFO)' })
        )

        vim.keymap.set('n', '<leader>rp', function()
            if not explain_check_psql(buf_sql(args.buf)) then
                return
            end
            local csv = query_out_path(path, 'csv')
            local cmd, out = csv_to_parquet(
                string.format(
                    "psql -q -v ON_ERROR_STOP=1 -P pager=off -c 'SET client_min_messages = error;' --csv -f %s > %s",
                    vim.fn.shellescape(path),
                    vim.fn.shellescape(csv)
                ),
                csv
            )
            run_to_visidata_tmux(cmd, out, 'psql query', vim.fn.expand '~/data/postgres/')
        end, vim.tbl_extend('force', bufopt, { desc = 'psql → EXPLAIN → CSV → parquet → visidata (tmux)' }))

        vim.keymap.set('n', '<leader>rj', function()
            if not explain_check_psql(buf_sql(args.buf)) then
                return
            end
            local out = query_out_path(path, 'jsonl')
            local cmd = string.format(
                "psql -q -v ON_ERROR_STOP=1 -P pager=off -At -c 'SET client_min_messages = error;' -f %s > %s",
                vim.fn.shellescape(path),
                vim.fn.shellescape(out)
            )
            run_to_visidata_tmux(cmd, out, 'psql query (json)', vim.fn.expand '~/data/postgres/')
        end, vim.tbl_extend('force', bufopt, { desc = 'psql → JSONL → visidata (tmux)' }))

        -- Same queries, but results land in a new vim buffer (CSV) instead of visidata.
        vim.keymap.set('n', '<leader>rS', function()
            local out = query_out_path(path, 'csv')
            local cmd =
                string.format('snow sql --format csv -f %s > %s', vim.fn.shellescape(path), vim.fn.shellescape(out))
            run_to_vim_buffer(cmd, out, 'snow query')
        end, vim.tbl_extend('force', bufopt, { desc = 'snow → CSV → vim buffer' }))

        vim.keymap.set('n', '<leader>rP', function()
            if not explain_check_psql(buf_sql(args.buf)) then
                return
            end
            local out = query_out_path(path, 'csv')
            local cmd = string.format(
                "psql -q -v ON_ERROR_STOP=1 -P pager=off -c 'SET client_min_messages = error;' --csv -f %s > %s",
                vim.fn.shellescape(path),
                vim.fn.shellescape(out)
            )
            run_to_vim_buffer(cmd, out, 'psql query')
        end, vim.tbl_extend('force', bufopt, { desc = 'psql → EXPLAIN → CSV → vim buffer' }))
    end,
})

--- custom keymaps ---

map('n', '<leader>T', function()
    require('config.timetracking').open_week()
end, { desc = 'Open time tracker' })

-- Code runner: write the buffer and run it in a tmux pane beside nvim. Replaces
-- the old `:!python3 %`, which blocked nvim and threw the output away on the
-- next keypress. See config/coderunner.lua for the interpreter table.
map('n', '<leader>xx', function()
    require('config.coderunner').run()
end, { desc = 'run this file in the tmux run window' })
map('n', '<leader>xv', function()
    require('config.coderunner').run { split = 'h' }
end, { desc = 'run this file in a side pane instead of the run window' })

-- Run the current buffer in tmux's "run" window, reusing the same resolution as
-- prefix+r: .tmux-run, then RUN_COMMAND from .envrc via direnv, then
-- just/make, then the interpreter for the file's extension. The buffer path is
-- substituted for `{}` in the command, or appended if there is no placeholder.
--
-- Beats `:!python3 %` for anything long-running: output stays in a real pane you
-- can scroll and keep, and nvim is not blocked while it runs.
map('n', '<leader>rr', function()
    if vim.bo.buftype ~= '' or vim.api.nvim_buf_get_name(0) == '' then
        vim.notify('no file in this buffer', vim.log.levels.WARN)
        return
    end
    if not vim.env.TMUX then
        vim.notify('not inside tmux', vim.log.levels.ERROR)
        return
    end
    vim.cmd 'silent write'
    local file = vim.api.nvim_buf_get_name(0)
    vim.system({ 'tmux-run-command', file }, { text = true }, function(res)
        if res.code ~= 0 then
            vim.schedule(function()
                vim.notify('tmux-run-command failed: ' .. ((res.stderr ~= '' and res.stderr) or ('exit ' .. res.code)), vim.log.levels.ERROR)
            end)
        end
    end)
end, { desc = 'run current buffer in tmux run window' })
map('n', '<leader>e', function()
    if vim.bo.filetype == 'netrw' then
        vim.cmd 'bd'
    else
        vim.cmd 'Ex'
    end
end, { desc = 'Toggle NetRW' })
map('n', '<leader>"', '<cmd>registers<cr>', { desc = 'List registers' })
map('n', '<leader>tw', '<cmd>set wrap!<cr>', { desc = 'Toggle word wrap' })
-- map({ 'n', 'v' }, 'p', ']p')

-- German umlaut shortcuts, buffer-local to ~/notes. They used to be global,
-- which mangled ordinary typing everywhere else: "queue" became "qü"+"ue",
-- "value" -> "valü", and `sz` hit variable names. Prose in ~/notes is where the
-- trade is worth it.
--
-- BufNewFile as well as BufReadPost, so a brand new note gets them too. The
-- pattern is an absolute path, and `*` in an autocmd pattern spans `/`, so
-- subdirectories of ~/notes are covered.
local umlauts = { ue = 'ü', oe = 'ö', ae = 'ä', sz = 'ß' }

vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufNewFile' }, {
    group = vim.api.nvim_create_augroup('notes-umlauts', { clear = true }),
    pattern = vim.fn.expand '~/notes' .. '/*',
    desc = 'umlaut digraphs for notes',
    callback = function(args)
        for lhs, rhs in pairs(umlauts) do
            vim.keymap.set('i', lhs, rhs, { buffer = args.buf, desc = 'insert ' .. rhs })
        end
    end,
})

-- Vim motion keymaps
map({ 'n', 'i' }, '<C-k>', '<C-a>', { noremap = true })
map('i', 'kj', '<ESC>', { noremap = true })
map({ 'n', 'v' }, 'gl', 'L')
map({ 'n', 'v' }, 'L', '%')
map({ 'n', 'v' }, 'J', '<C-e>j')
map({ 'n', 'v' }, 'K', '<C-y>k')
map({ 'n', 'v' }, 'gh', 'H')
map({ 'n', 'v' }, 'H', 'J')
map('n', 'zk', 'zt')
map('n', 'zj', 'zb')
-- map({ 'n', 'v' }, '<C-e>', 'J')
map({ 'n', 'v' }, '<C-d>', '<C-d>zz')
map({ 'n', 'v' }, '<C-u>', '<C-u>zz')
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
map('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
map('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
map('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
map('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Prev Search Result' })
-- better up/down
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { desc = 'Down', expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { desc = 'Up', expr = true, silent = true })
--
--keywordprg
map('n', '<leader>K', '<cmd>norm! K<cr>', { desc = 'Keywordprg' })

-- better indenting
map('x', '<', '<gv')
map('x', '>', '>gv')

-- commenting
map('n', 'gco', 'o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Below' })
map('n', 'gcO', 'O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>', { desc = 'Add Comment Above' })

-- yank / delete / visual behavior
map('n', '<leader>d.', 'diwsdb', { noremap = false, silent = true })
map('n', '<leader>w', 'yiw', { noremap = true, silent = true })
map('v', '<leader>p', '"_dP')
map({ 'n', 'v' }, '<leader>d', '"_d')
-- map({ 'n', 'i', 'v' }, '<C-_>', '<Plug>(comment_toggle_linewise)')
map('n', '<leader>yf', function()
    vim.fn.setreg('+', vim.fn.expand '%:p')
    vim.notify('copied: ' .. vim.fn.expand '%:p')
end, { desc = 'Yank full path of current buffer' })

-- Buffer/window management
map(
    { 'n', 'i', 'v' },
    '<C-s>',
    '<cmd>noautocmd w<cr>',
    { noremap = true, desc = 'Save current buffer (without formatting)' }
)
-- Normal mode only: in insert mode these made <C-w> an ambiguous prefix, so
-- deleting the previous word waited out timeoutlen (500ms) before falling back
-- to the built-in i_CTRL-W.
map('n', '<C-W><C-Q>', '<cmd>qa<cr>', { noremap = true, desc = 'Quit all windows', silent = true })
map('n', '<C-W><C-X>', '<cmd>q!<cr>', { noremap = true, desc = 'Quit all windows', silent = true })
map({ 'n', 'i' }, '<C-S><C-S>', '<cmd>wq<cr>', { noremap = true, desc = 'Quit all windows', silent = true })
map('n', '<leader>q', ':bdelete<CR>', { noremap = true, desc = 'Close current buffer' })
map({ 'n', 'v' }, '<Leader>v', ':vsplit<CR>', { noremap = true, silent = true, desc = 'New vertical split' })
map({ 'n', 'v' }, '<Leader>tn', ':tabnew<CR>', { noremap = true, silent = true, desc = 'New vertical split' })
map({ 'n', 'v' }, '<Tab>', '<C-^>', { noremap = true, silent = true, desc = 'Last buffer' }) -- this is defined in functions.lua
map('n', '<Leader>rm', 'mz:%s/\\r//g<CR>`z', { desc = 'Remove Carriage Returns From Buffer' })

map({ 'n', 'v' }, '<Leader>n', function()
    vim.cmd 'enew'
    vim.opt_local.buftype = 'nofile'
    vim.opt_local.bufhidden = 'wipe'
    vim.opt_local.swapfile = false
    vim.opt_local.modifiable = true
end, {
    noremap = true,
    silent = true,
    desc = 'Open scratch buffer',
})
map({ 'n', 'v' }, '<Leader>rr', function()
    vim.cmd 'e!'
    vim.cmd 'LspRestart'
    vim.cmd [[echo "file reloaded"]]
end, {
    noremap = true,
    desc = 'Force reload current buffer (discard any changes)',
})

-- Plugin specific keymaps
-- map('n', '<leader>i', ':lua require("iris").toggle_quick_menu()<CR>', { noremap = true, silent = true })
-- map('n', '<leader>co', ':lua require("iris").prompt_openai()<CR>', { noremap = true, silent = true })
-- map('n', '<leader>cc', ':lua require("iris").prompt_claudeai()<CR>', { noremap = true, silent = true })

-- Diagnostic keymaps
local enabled = true
function ToggleDiagnosticsVirtualText()
    enabled = not enabled
    vim.diagnostic.config { virtual_text = enabled }
end
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show [d]iagnostic [E]rror messages' })
map('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open [d]iagnostic [q]uickfix list' })
map('n', '<leader>td', ToggleDiagnosticsVirtualText, { desc = '[T]oggle [d]iagnostics (usercmd)}' })

-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

--  See `:help wincmd` for a list of all window commands
map('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
map('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
map('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
map('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
