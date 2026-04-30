return {
    'obsidian-nvim/obsidian.nvim',
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
    opts = {
        ---@type obsidian.config.Internal
        -- TODO: remove these in 4.0.0
        legacy_commands = false,

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
        notes_subdir = nil,
        new_notes_location = 'current_dir',

        log_level = vim.log.levels.INFO,
        -- Default random zettel IDs. To use readable UTF-8 slug IDs, set:
        -- note_id_func = require("obsidian.builtin").title_id
        --
        ---@class obsidian.config.NoteOpts
        ---
        ---Default template to use, relative to template.folder or an absolute path.
        ---The default looks like:
        ---
        ---```markdown
        ------
        ---id: {{id}}
        ---aliases: []
        ---tags: []
        ------
        ---```
        ---
        ---@field template string|?
        note = {
            template = (function()
                local root = vim.iter(vim.api.nvim_list_runtime_paths()):find(function(path)
                    return vim.endswith(path, 'obsidian.nvim')
                end)
                if not root then
                    return nil
                end
                return vim.fs.joinpath(root, 'data/default_template.md')
            end)(),
        },

        ---@class obsidian.config.FrontmatterOpts
        ---
        --- Whether to enable frontmatter, boolean for global on/off, or a function that takes filename and returns boolean.
        ---@field enabled? (fun(fname: string?): boolean)|boolean
        ---
        --- Function to turn Note attributes into frontmatter.
        ---@field func? fun(note: obsidian.Note): table<string, any>
        --- Function that is passed to table.sort to sort the properties, or a fixed order of properties.
        ---
        ---@class obsidian.config.TemplateOpts
        ---
        ---@field enabled boolean|?
        ---@field folder string|obsidian.Path|?
        ---@field date_format string
        ---@field time_format string
        --- A map for custom variables, the key should be the variable and the value a function.
        --- Functions are called with obsidian.TemplateContext objects and optional suffix strings.
        --- See: https://github.com/obsidian-nvim/obsidian.nvim/wiki/Template#substitutions
        ---@field substitutions table<string, string|fun(ctx: obsidian.TemplateContext, suffix: string|?):string|?>
        ---@field customizations table<string, obsidian.config.CustomTemplateOpts>|?
        templates = {
            enabled = false,
            folder = nil,
            date_format = 'YYYY-MM-DD',
            time_format = 'HH:mm',
            substitutions = {
                date = function(_, suffix)
                    local format = suffix or Obsidian.opts.templates.date_format
                    return require('obsidian.util').format_date(os.time(), format)
                end,
                time = function(_, suffix)
                    local format = suffix or Obsidian.opts.templates.time_format
                    return require('obsidian.util').format_date(os.time(), format)
                end,
                title = function(ctx)
                    return ctx.partial_note and ctx.partial_note:display_name()
                end,
                id = function(ctx)
                    return ctx.partial_note and ctx.partial_note.id
                end,
                path = function(ctx)
                    return ctx.partial_note and tostring(ctx.partial_note.path)
                end,
            },

            ---@class obsidian.config.CustomTemplateOpts
            ---
            ---@field notes_subdir? string
            ---@field note_id_func? (fun(title: string|?, path: obsidian.Path|?): string)
            customizations = {},
        },

        ---@class obsidian.config.BacklinkOpts
        ---
        ---@field parse_headers boolean
        backlinks = {
            parse_headers = true,
        },

        ---@class obsidian.config.CompletionOpts
        ---
        ---@field nvim_cmp? boolean
        ---@field blink? boolean
        ---@field min_chars? integer
        ---@field match_case? boolean
        ---@field create_new? boolean
        completion = (function()
            local has_nvim_cmp, _ = pcall(require, 'cmp')
            local has_blink = pcall(require, 'blink.cmp')
            return {
                nvim_cmp = has_nvim_cmp and not has_blink,
                blink = has_blink,
                min_chars = 2,
                match_case = true,
                create_new = true,
            }
        end)(),

        ---@class obsidian.config.PickerNoteMappingOpts
        ---
        ---@field new? string
        ---@field insert_link? string

        ---@class obsidian.config.PickerTagMappingOpts
        ---
        ---@field tag_note? string
        ---@field insert_tag? string

        ---@class obsidian.config.PickerOpts
        ---
        ---@field name obsidian.config.Picker|?
        ---@field note_mappings? obsidian.config.PickerNoteMappingOpts
        ---@field tag_mappings? obsidian.config.PickerTagMappingOpts
        picker = {
            name = nil,
            note_mappings = {
                new = '<C-x>',
                insert_link = '<C-l>',
            },
            tag_mappings = {
                tag_note = '<C-x>',
                insert_tag = '<C-l>',
            },
        },

        ---@class obsidian.config.SearchOpts
        ---
        ---@field sort_by string
        ---@field sort_reversed boolean
        ---@field max_lines integer
        search = {
            sort_by = 'modified',
            sort_reversed = true,
            max_lines = 1000,
        },

        ---@class obsidian.config.DailyNotesOpts
        ---
        ---@field enabled? boolean
        ---@field folder? string
        ---@field date_format? string
        ---@field alias_format? string
        ---@field template? string
        ---@field default_tags? string[]
        ---@field workdays_only? boolean
        daily_notes = {
            enabled = true,
            folder = nil,
            date_format = 'YYYY-MM-DD',
            alias_format = nil,
            default_tags = { 'daily-notes' },
            workdays_only = true,
        },

        ---@class obsidian.config.CallbackConfig
        ---
        ---Runs right after setup
        ---@field post_setup? fun()
        ---
        ---Runs when entering a note buffer.
        ---@field enter_note? fun(note: obsidian.Note)
        ---
        ---Runs when leaving a note buffer.
        ---@field leave_note? fun(note: obsidian.Note)
        ---
        ---Runs right before writing a note buffer.
        ---@field pre_write_note? fun(note: obsidian.Note)
        ---
        ---Runs anytime the workspace is set/changed.
        ---@field post_set_workspace? fun(workspace: obsidian.Workspace)
        callbacks = {
            enter_note = function()
                local map = function(mode, lhs, rhs, desc)
                    vim.keymap.set(mode, lhs, rhs, { buffer = true, desc = 'Obsidian: ' .. desc })
                end
                map('n', '<leader>oo', '<cmd>Obsidian quick_switch<CR>', 'Quick Switch')
                map('n', '<leader>og', '<cmd>Obsidian search<CR>', 'Grep Notes')
                map('n', '<leader>ot', function()
                    vim.lsp.buf.document_symbol {
                        on_list = function(t)
                            for _, item in ipairs(t.items) do
                                item.text = item.text:gsub('^%[%w+%]%s*', '')
                            end
                            vim.api.nvim_feedkeys('', 'nx', true)
                            if Obsidian.picker then
                                Obsidian.picker.pick(t.items, {
                                    prompt_title = 'Table of Contents',
                                    format_item = function(item) return item.text end,
                                })
                            else
                                vim.fn.setloclist(0, {}, ' ', t)
                                vim.cmd('lopen')
                            end
                        end,
                    }
                end, 'Table of Contents')
                map('n', '<leader>oT', function()
                    vim.lsp.buf.document_symbol {
                        on_list = function(t)
                            for _, item in ipairs(t.items) do
                                item.text = item.text:gsub('^%[%w+%]%s*', '')
                            end
                            vim.fn.setqflist({}, ' ', {
                                title = 'Table of Contents',
                                items = t.items,
                                quickfixtextfunc = function(info)
                                    local list = vim.fn.getqflist({ id = info.id, items = 1 }).items
                                    local lines = {}
                                    for idx = info.start_idx, info.end_idx do
                                        local it = list[idx]
                                        lines[#lines + 1] = (it and it.text) or ''
                                    end
                                    return lines
                                end,
                            })
                            vim.cmd('copen')
                        end,
                    }
                end, 'TOC quick-list')
                map('n', '<leader>od', '<cmd>Obsidian dailies<CR>', 'Dailies')
                map('n', '<leader>on', '<cmd>Obsidian new<CR>', 'New Note')
                map('n', '<leader>or', '<cmd>Obsidian rename<CR>', 'Rename Note')
                map('n', '<leader>of', '<cmd>Obsidian tags<CR>', 'Find by Tag')
                map('n', '<leader>ow', '<cmd>Obsidian workspace<CR>', 'Select Workspace')
                map('n', '<leader>ob', '<cmd>Obsidian backlinks<CR>', 'Backlinks')
                map('n', '<leader>ol', '<cmd>Obsidian links<CR>', 'Links')
                map('n', '<leader><leader>', '<cmd>Obsidian toggle_checkbox<CR>', 'Toggle Checkbox')
                map('n', '<leader>oa', function()
                    local save = vim.fn.winsaveview()
                    vim.cmd('silent! /^tags:/')
                    local line = vim.fn.getline('.')
                    if line:match('^tags:') then
                        vim.cmd('nohlsearch')
                        vim.cmd('normal! A ')
                        vim.cmd('startinsert!')
                    else
                        vim.fn.winrestview(save)
                        vim.notify('No tags: field found in frontmatter', vim.log.levels.WARN)
                    end
                end, 'Add Tag')
            end,
        },

        ---@class obsidian.config.FooterOpts
        ---
        ---@field enabled? boolean
        ---@field format? string
        ---@field hl_group? string
        ---@field separator? string|false Set false to disable separator; set an empty string to insert a blank line separator.
        footer = {
            enabled = true,
            format = '{{backlinks}} backlinks  {{properties}} properties  {{words}} words  {{chars}} chars',
            hl_group = 'Comment',
            separator = string.rep('-', 80),
        },

        ---@class obsidian.config.OpenOpts
        ---
        ---Opens the file with current line number
        ---@field use_advanced_uri? boolean
        ---
        ---Function to do the opening, default to vim.ui.open
        ---@field func? fun(uri: string)
        ---
        ---URI scheme whitelist, new values are appended to this list, and URIs with schemes in this list, will not be prompted to confirm opening
        ---@field schemes? string[]
        open = {
            use_advanced_uri = false,
            func = vim.ui.open,
            schemes = { 'https', 'http', 'file', 'mailto' },
        },

        ---@class obsidian.config.CheckboxOpts
        ---
        ---@field enabled? boolean
        ---
        ---Order of checkbox state chars, e.g. { " ", "x" }
        ---@field order? string[]
        ---
        ---Whether to create new checkbox on paragraphs
        ---@field create_new? boolean
        checkbox = {
            enabled = true,
            create_new = true,
            order = { ' ', 'x' },
        },

        ---@class obsidian.config.CommentOpts
        ---@field enabled boolean
        comment = {
            enabled = false,
        },
    },
    config = function(_, opts)
        local p = require('rose-pine.palette')

        opts.ui = vim.tbl_deep_extend('force', opts.ui or {}, {
            enable = true,
            bullets = { char = '•', hl_group = 'ObsidianBullet' },
            external_link_icon = { char = '', hl_group = 'ObsidianExtLinkIcon' },
            reference_text = { hl_group = 'ObsidianRefText' },
            highlight_text = { hl_group = 'ObsidianHighlightText' },
            tags = { hl_group = 'ObsidianTag' },
            block_ids = { hl_group = 'ObsidianBlockID' },
            hl_groups = {
                ObsidianTodo = { fg = p.gold, bold = true },
                ObsidianInProgress = { fg = p.foam, bold = true },
                ObsidianDone = { fg = p.muted },
                ObsidianCancelled = { fg = p.muted, strikethrough = true },
                ObsidianForwarded = { fg = p.foam, bold = true },
                ObsidianImportant = { fg = p.love, bold = true },
                ObsidianQuestion = { fg = p.iris, bold = true },
                ObsidianTilde = { fg = p.subtle },
                ObsidianRightArrow = { fg = p.foam, bold = true },
                ObsidianBullet = { fg = p.subtle },
                ObsidianRefText = { fg = p.iris, underline = true },
                ObsidianExtLinkIcon = { fg = p.iris },
                ObsidianTag = { fg = p.foam, italic = true },
                ObsidianBlockID = { fg = p.subtle, italic = true },
                ObsidianHighlightText = { fg = p.base, bg = p.gold },
            },
        })

        require('obsidian').setup(opts)

        -- Re-apply hl_groups on ColorScheme so they survive theme reloads
        vim.api.nvim_create_autocmd('ColorScheme', {
            callback = function()
                local pal = require('rose-pine.palette')
                for name, val in pairs({
                    ObsidianTodo = { fg = pal.gold, bold = true },
                    ObsidianInProgress = { fg = pal.foam, bold = true },
                    ObsidianDone = { fg = pal.muted },
                    ObsidianCancelled = { fg = pal.muted, strikethrough = true },
                    ObsidianForwarded = { fg = pal.foam, bold = true },
                    ObsidianImportant = { fg = pal.love, bold = true },
                    ObsidianQuestion = { fg = pal.iris, bold = true },
                    ObsidianTilde = { fg = pal.subtle },
                    ObsidianRightArrow = { fg = pal.foam, bold = true },
                    ObsidianBullet = { fg = pal.subtle },
                    ObsidianRefText = { fg = pal.iris, underline = true },
                    ObsidianExtLinkIcon = { fg = pal.iris },
                    ObsidianTag = { fg = pal.foam, italic = true },
                    ObsidianBlockID = { fg = pal.subtle, italic = true },
                    ObsidianHighlightText = { fg = pal.base, bg = pal.gold },
                }) do
                    vim.api.nvim_set_hl(0, name, val)
                end
            end,
        })
    end,
}
