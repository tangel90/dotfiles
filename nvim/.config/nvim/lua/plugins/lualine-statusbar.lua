return {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        local custom_scheme = require 'lualine.themes.auto'
        custom_scheme.normal.a.bg = '#282C34'
        custom_scheme.insert.a.bg = '#282C34'
        custom_scheme.visual.a.bg = '#282C34'
        custom_scheme.normal.b.bg = '#282C34'
        custom_scheme.insert.b.bg = '#282C34'
        custom_scheme.visual.b.bg = '#282C34'
        custom_scheme.insert.c.bg = '#282C34'
        custom_scheme.normal.c.bg = '#282C34'
        custom_scheme.visual.c.bg = '#282C34'
        custom_scheme.command.c.bg = '#282C34'
        -- custom_everforest.normal.x.fg = '#ebbcba'

        require('lualine').setup {
            options = {
                icons_enabled = true,
                theme = custom_scheme,
                component_separators = { left = '', right = '', color = { fg = '#999cba' } },
                section_separators = { left = ' > ', right = ' < ', color = { fg = '#999cba' } },
                disabled_filetypes = {
                    statusline = {},
                    winbar = {},
                },
                ignore_focus = {},
                always_divide_middle = true,
                always_show_tabline = true,
                globalstatus = false,
                refresh = {
                    statusline = 1000,
                    tabline = 1000,
                    winbar = 1000,
                    refresh_time = 16, -- ~60fps
                    events = {
                        'WinEnter',
                        'BufEnter',
                        'BufWritePost',
                        'SessionLoadPost',
                        'FileChangedShellPost',
                        'VimResized',
                        'Filetype',
                        'CursorMoved',
                        'CursorMovedI',
                        'ModeChanged',
                    },
                },
            },
            sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {
                    '%=',
                    {
                        'filetype',
                        icon_only = true,
                        -- color = { fg = '#e0def4', bg = '#282C34' },
                    },
                    {
                        'filename',
                        file_status = true, -- Displays file status (readonly status, modified status)
                        newfile_status = false, -- Display new file status (new file means no write after created)
                        path = 0, -- 0: Just the filename
                        -- 1: Relative path
                        -- 2: Absolute path
                        -- 3: Absolute path, with tilde as the home directory
                        -- 4: Filename and parent dir, with tilde as the home directory
                        -- padding = { left = 80, right = 0},
                        shorting_target = 40, -- Shortens path to leave 40 spaces in the window
                        -- for other components. (terrible name, any suggestions?)
                        -- It can also be a function that returns
                        -- the value of `shorting_target` dynamically.
                        symbols = {
                            modified = '[+]', -- Text to show when the file is modified.
                            readonly = '[-]', -- Text to show when the file is non-modifiable or readonly.
                            unnamed = '[No Name]', -- Text to show for unnamed buffers.
                            newfile = '[New]', -- Text to show for newly created file before first write
                        },
                        color = { fg = '#e0def4', bg = '#282C34' },
                    },
                },
                lualine_x = {},
                lualine_y = {
                    { 'diagnostics', colored = false, color = { fg = '#999cba', bg = '#282C34' } },
                },
                lualine_z = {
                    { 'diff', colored = false, color = { fg = '#999cba', bg = '#282C34' } },
                    { 'branch', color = { fg = '#999cba', bg = '#282C34', gui = 'bold' }, padding = { left = 2 } },
                },
            },
            inactive_sections = {
                lualine_a = {},
                lualine_b = {},
                lualine_c = {},
                lualine_x = {},
                lualine_y = {},
                lualine_z = {},
            },
            tabline = {},
            extensions = {},
        }
        -- vim.opt.laststatus = 0
        -- vim.go.laststatus = 0
    end,
}
