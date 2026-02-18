return {
    'epwalsh/obsidian.nvim',
    version = '*', -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = 'markdown',
    -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
    -- event = {
    --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
    --   -- refer to `:h file-pattern` for more examples
    --   "BufReadPre path/to/my-vault/*.md",
    --   "BufNewFile path/to/my-vault/*.md",
    -- },
    dependencies = {
        -- Required.
        'nvim-lua/plenary.nvim',
        -- see below for full list of optional dependencies 👇
    },
    opts = {
        workspaces = {
            {
                name = 'personal',
                path = os.getenv 'NOTES_HOME' or '~/notes',
            },
            -- {
            --   name = 'work',
            --   path = '~/obsidian/whoishydra',
            -- },
            {
                name = 'no-vault',
                path = function()
                    -- alternatively use the CWD:
                    -- return assert(vim.fn.getcwd())
                    return assert(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))
                end,
                disable_frontmatter = true,
                overrides = {
                    notes_subdir = vim.NIL, -- have to use 'vim.NIL' instead of 'nil'
                    new_notes_location = 'current_dir',
                },
            },
        },

        -- notes_subdir = 'notes',

        -- Optional, set the log level for obsidian.nvim. This is an integer corresponding to one of the log
        -- levels defined by "vim.log.levels.*".
        log_level = vim.log.levels.INFO,

        daily_notes = {
            -- Optional, if you keep daily notes in a separate directory.
            -- folder = 'notes/dailies',
            -- Optional, if you want to change the date format for the ID of daily notes.
            date_format = '%Y-%m-%d',
            -- Optional, if you want to change the date format of the default alias of daily notes.
            alias_format = '%B %-d, %Y',
            -- Optional, default tags to add to each new daily note created.
            default_tags = { 'daily-notes' },
            -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
            template = nil,
        },

        -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
        completion = {
            -- Set to false to disable completion.
            nvim_cmp = true,
            -- Trigger completion at 2 chars.
            min_chars = 2,
        },

        -- Optional, configure key mappings. These are the defaults. If you don't want to set any keymappings this
        -- way then set 'mappings = {}'.
        mappings = {
            -- Overrides the 'gf' mapping to work on markdown/wiki links within your vault.
            ['gf'] = {
                action = function()
                    return require('obsidian').util.gf_passthrough()
                end,
                opts = { noremap = false, expr = true, buffer = true, desc = 'Obsidian: gf_passthrough' },
            },
            ['<leader>og'] = {
                action = '<cmd>ObsidianSearch<CR>',
                opts = { buffer = true, desc = 'Obsidian: [G]rep in Notes' },
            },
            ['<leader>oo'] = {
                action = '<cmd>ObsidianQuickSwitch<CR>',
                opts = { buffer = true, desc = 'Obsidian: [O]pen QuickSwitch' },
            },
            ['<leader>ot'] = {
                action = '<cmd>ObsidianTOC<CR>',
                opts = { buffer = true, desc = 'Obsidian: Show [T]oc' },
            },
            ['<leader>od'] = {
                action = '<cmd>ObsidianDailies<CR>',
                opts = { buffer = true, desc = 'Obsidian: Open [D]ailies' },
            },
            ['<leader>or'] = {
                action = '<cmd>ObsidianRename<CR>',
                opts = { buffer = true, desc = 'Obsidian: [R]ename Note' },
            },
            ['<leader>of'] = {
                action = '<cmd>ObsidianTag<CR>',
                opts = { buffer = true, desc = 'Obsidian: [F]ind by Tag' },
            },
            ['<leader>ow'] = {
                action = '<cmd>ObsidianWorkspace<CR>',
                opts = { buffer = true, desc = 'Obsidian: Select [W]orkspace' },
            },
            ['<leader>on'] = {
                action = '<cmd>ObsidianNew<CR>',
                opts = { buffer = true, desc = 'Obsidian: [N]ew Note' },
            },
            -- Toggle check-boxes.
            ['<leader><leader>'] = {
                action = function()
                    return require('obsidian').util.toggle_checkbox()
                end,
                opts = { buffer = true },
            },
            ['gl'] = {
                action = '<cmd>ObsidianFollowLink<CR>',
                opts = { buffer = true, desc = 'Obsidian: Follow Link' },
            },
            -- Smart action depending on context, either follow link or toggle checkbox.
            ['gd'] = {
                action = function()
                    return require('obsidian').util.smart_action()
                end,
                opts = { buffer = true, expr = true, desc = 'Obsidian: Smart Action' },
            },

            ['<cr>'] = {
                action = function()
                    return require('obsidian').util.smart_action()
                end,
                opts = { buffer = true, expr = true, desc = 'Obsidian: Smart Action' },
            },
        },
        ui = {
            enable = false, -- set to false to disable all additional syntax features
            update_debounce = 200, -- update delay after a text change (in milliseconds)
            max_file_length = 5000, -- disable UI features for files with more than this many lines
            -- Define how various check-boxes are displayed
            checkboxes = {
                -- NOTE: the 'char' value has to be a single character, and the highlight groups are defined below.
                [' '] = { char = '󰄱', hl_group = 'ObsidianTodo' },
                ['x'] = { char = '', hl_group = 'ObsidianDone' },
                ['>'] = { char = '', hl_group = 'ObsidianRightArrow' },
                ['~'] = { char = '󰰱', hl_group = 'ObsidianTilde' },
                ['!'] = { char = '', hl_group = 'ObsidianImportant' },
                -- Replace the above with this if you don't have a patched font:
                -- [" "] = { char = "☐", hl_group = "ObsidianTodo" },
                -- ["x"] = { char = "✔", hl_group = "ObsidianDone" },

                -- You can also add more custom ones...
            },
            -- Use bullet marks for non-checkbox lists.
            bullets = { char = '•', hl_group = 'ObsidianBullet' },
            external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
            -- Replace the above with this if you don't have a patched font:
            -- external_link_icon = { char = "", hl_group = "ObsidianExtLinkIcon" },
            reference_text = { hl_group = 'ObsidianRefText' },
            highlight_text = { hl_group = 'ObsidianHighlightText' },
            tags = { hl_group = 'ObsidianTag' },
            block_ids = { hl_group = 'ObsidianBlockID' },
            hl_groups = {
                -- The options are passed directly to `vim.api.nvim_set_hl()`. See `:help nvim_set_hl`.
                ObsidianTodo = { bold = true, fg = '#f78c6c' },
                ObsidianDone = { bold = true, fg = '#89ddff' },
                ObsidianRightArrow = { bold = true, fg = '#f78c6c' },
                ObsidianTilde = { bold = true, fg = '#ff5370' },
                ObsidianImportant = { bold = true, fg = '#d73128' },
                ObsidianBullet = { bold = true, fg = '#89ddff' },
                ObsidianRefText = { underline = true, fg = '#c792ea' },
                ObsidianExtLinkIcon = { fg = '#c792ea' },
                ObsidianTag = { italic = true, fg = '#89ddff' },
                ObsidianBlockID = { italic = true, fg = '#89ddff' },
                ObsidianHighlightText = { bg = '#75662e' },
            },
        },
        -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
        -- URL it will be ignored but you can customize this behavior here.
        ---@param url string
        follow_url_func = function(url)
            vim.ui.open(url) -- need Neovim 0.10.0+
        end,
    },
    config = function(_, opts)
        local obsidian = require 'obsidian'

        obsidian.setup(opts)
        vim.keymap.set('i', '<C-m>', obsidian.util.toggle_checkbox, { desc = 'Toggle Checkbox' })
    end,
}
