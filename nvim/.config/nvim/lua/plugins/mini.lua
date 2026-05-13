return { -- Collection of various small independent plugins/modules
    'nvim-mini/mini.nvim',
    config = function()
        -- Better [A]round/[I]nside textobjects
        -- Examples for extended text object motions that mini.ai offers:
        --  - va)  - [V]isually select [A]round [)]paren
        --  - yinq - [Y]ank [I]nside [N]ext [']quote
        --  - ci'  - [C]hange [I]nside [']quote
        require('mini.ai').setup {
            n_lines = 500,
            custom_textobjects = {
                c = { '\n```%w*\n().-()\n```' },
            },
        }

        vim.keymap.set('n', '<leader>cb', 'yic', { remap = true, desc = 'Yank markdown code [B]lock' })
        vim.keymap.set('v', '<leader>cb', '<Esc>vic', { remap = true, desc = 'Select markdown code [B]lock' })

        -- require('mini.icons').setup()
        -- require('mini.completion').setup {}
        -- Add/delete/replace surroundings (brackets, quotes, etc.)
        --
        -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
        -- - sd'   - [S]urround [D]elete [']quotes
        -- - sr)'  - [S]urround [R]eplace [)] [']
        require('mini.surround').setup()

        vim.keymap.set('n', '<leader>ss', ':normal saiw"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>.', ':normal saiw"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>s.', ':normal saiw"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>s"', ':normal saiw"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', "<leader>s'", ":normal saiw'<CR>", { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>sq', ':normal saiw"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>sb', ':normal saiw)<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>sB', ':normal saiw}<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>s]', ':normal saiw]<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>s}', ':normal saiw}<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>S"', ':normal saiW"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>Sq', ':normal saiW"<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>Sb', ':normal saiW)<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>SB', ':normal saiW}<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '<leader>S]', ':normal saiW]<CR>', { noremap = true, silent = true })

        -- Simple and easy statusline.
        --  You could remove this setup call if you don't like it,
        --  and try some other statusline plugin
        -- set use_icons to true if you have a Nerd Font

        -- You can configure sections in the statusline by overriding their
        -- default behavior. For example, here we set the section for
        -- cursor location to LINE:COLUMN
        -- @diagnostic disable-next-line: duplicate-set-field
        -- statusline.section_location = function()
        --   return '%2l:%-2v'
        -- end

        -- ... and there is more!
        --  Check out: https://github.com/echasnovski/mini.nvim
        require('mini.files').setup {
            -- No need to copy this inside `setup()`. Will be used automatically.
            -- Customization of shown content
            content = {
                -- Predicate for which file system entries to show
                filter = nil,
                -- Highlight group to use for a file system entry
                highlight = nil,
                -- Prefix text and highlight to show to the left of file system entry
                prefix = nil,
                -- Order in which to show file system entries
                sort = nil,
            },

            -- Module mappings created only inside explorer.
            -- Use `''` (empty string) to not create one.
            mappings = {
                -- close = '<ESC><ESC>',
                close = 'q',
                go_in = 'l',
                go_in_plus = '<CR>',
                go_out = 'H',
                go_out_plus = 'h',
                mark_goto = "'",
                mark_set = 'm',
                reset = '<BS>',
                reveal_cwd = '.',
                show_help = 'g?',
                synchronize = '=',
                trim_left = '<',
                trim_right = '>',
            },

            -- General options
            options = {
                -- Whether to delete permanently or move into module-specific trash
                permanent_delete = true,
                -- Whether to use for editing directories
                use_as_default_explorer = true,
                -- Timeout for synchronous LSP integration requests
                lsp_timeout = 1000,
            },

            -- Customization of explorer windows
            windows = {
                -- Maximum number of windows to show side by side
                max_number = math.huge,
                -- Whether to show preview of file/directory under cursor
                preview = true,
                -- Width of focused window
                width_focus = 50,
                -- Width of non-focused window
                width_nofocus = 15,
                -- Width of preview window
                width_preview = 80,
            },
        }
        vim.keymap.set('n', '<leader>e', function()
            local mf = require 'mini.files'
            if not mf.close() then
                mf.open(vim.api.nvim_buf_get_name(0))
            end
        end, { desc = 'mini.files: toggle' })
    end,
}
