return {
    'OXY2DEV/markview.nvim',
    lazy = false,

    -- Completion for `blink.cmp`
    dependencies = { 'saghen/blink.cmp' },
    config = function()
        local opts = {}

        opts.preview = {
            modes = { 'n', 'i', 'c', 'niI', 'niR', 'no' },
            -- hybrid_modes = { 'n', 'i' }, -- this will disable preview only for blocks under cursor
            ignore_previews = {
                markdown = { '!code_blocks', '!block_quote', '!headings' },
                markdown_inline = { 'inline_codes' },
            },
            icon_provider = 'mini',
            -- debounce = 0,
        }

        opts.preview.callbacks = {
        	on_enable = function(_, wins)
        		for _, win in ipairs(wins) do
        			vim.wo[win].conceallevel = 2
        		end
        	end,
        }

        opts.markdown = {}

        opts.markdown.code_blocks = {
            enable = true,

            border_hl = 'MarkviewCode',
            info_hl = 'MarkviewCodeInfo',

            label_direction = 'right',
            label_hl = 'MarkviewCodeLabel',

            min_width = 50,
            pad_amount = 4,
            pad_char = ' ',

            default = {
                block_hl = 'MarkviewCode',
                pad_hl = 'MarkviewCode',
            },

            ['diff'] = { -- this will take care of git diff blocks
                block_hl = function(_, line)
                    if line:match '^%+' then
                        return 'MarkviewPalette4'
                    elseif line:match '^%-' then
                        return 'MarkviewPalette1'
                    else
                        return 'MarkviewCode'
                    end
                end,
                pad_hl = 'MarkviewCode',
            },

            style = 'block',
            sign = true,
        }

        opts.markdown.headings = {
            heading_1 = { style = 'icon' },
            heading_2 = { style = 'icon' },
            heading_3 = { style = 'icon' },
            heading_4 = { style = 'simple' },
            heading_5 = { style = 'simple' },
            heading_6 = { style = 'simple' },
            setext_1 = { style = 'simple' },
            setext_2 = { style = 'simple' },
        }

        local presets = require 'markview.presets'

        opts.markdown.horizontal_rules = presets.horizontal_rules.thick

        opts.markdown.tables = presets.tables.single

        opts.markdown.list_items = {
            indent_size = vim.opt_local.ts:get(),
            shift_width = vim.opt_local.sw:get(),

            marker_plus = { text = '+' },
            marker_minus = { text = '-' },
            marker_star = { text = '*' },
        }
        require('markview').setup(opts)

        -- Override markview colors to match rose-pine
        local p = require('rose-pine.palette')
        local hl = vim.api.nvim_set_hl

        -- Headings
        hl(0, 'MarkviewHeading1', { fg = p.iris, bold = true, underline = true })
        hl(0, 'MarkviewHeading2', { fg = p.foam, bold = true, underline = true })
        hl(0, 'MarkviewHeading3', { fg = p.rose, bold = true, underline = true })
        hl(0, 'MarkviewHeading4', { fg = p.gold, bold = true, underline = true })
        hl(0, 'MarkviewHeading5', { fg = p.pine, bold = true, underline = true })
        hl(0, 'MarkviewHeading6', { fg = p.foam, bold = true, underline = true })

        -- Heading sign column markers
        hl(0, 'MarkviewHeading1Sign', { fg = p.iris })
        hl(0, 'MarkviewHeading2Sign', { fg = p.foam })
        hl(0, 'MarkviewHeading3Sign', { fg = p.rose })
        hl(0, 'MarkviewHeading4Sign', { fg = p.gold })
        hl(0, 'MarkviewHeading5Sign', { fg = p.pine })
        hl(0, 'MarkviewHeading6Sign', { fg = p.foam })

        -- Checkboxes
        hl(0, 'MarkviewCheckboxUnchecked', { fg = p.leaf })
        hl(0, 'MarkviewCheckboxChecked', { fg = p.muted })
        hl(0, 'MarkviewCheckboxPending', { fg = p.gold })
        hl(0, 'MarkviewCheckboxCancelled', { fg = p.muted, strikethrough = true })

        -- Code blocks
        hl(0, 'MarkviewCode', { bg = p.base })
        hl(0, 'MarkviewCodeInfo', { fg = p.subtle, bg = p.base })
        hl(0, 'MarkviewCodeLabel', { fg = p.rose, bg = p.base })
        hl(0, 'MarkviewCodeSign', { fg = p.rose })
        hl(0, 'MarkviewInlineCode', { fg = p.foam })

        -- Block quotes
        hl(0, 'MarkviewBlockQuoteDefault', { fg = p.subtle })
        hl(0, 'MarkviewBlockQuoteError', { fg = p.love })
        hl(0, 'MarkviewBlockQuoteWarn', { fg = p.gold })
        hl(0, 'MarkviewBlockQuoteNote', { fg = p.foam })
        hl(0, 'MarkviewBlockQuoteOk', { fg = p.leaf })
        hl(0, 'MarkviewBlockQuoteSpecial', { fg = p.iris })

        -- Links
        hl(0, 'MarkviewHyperlink', { fg = p.iris, underline = true })
        hl(0, 'MarkviewImage', { fg = p.iris, underline = true })
        hl(0, 'MarkviewEmail', { fg = p.foam, underline = true })

        -- Body text
        hl(0, '@spell.markdown', { fg = '#d9d4d6' })

        -- Lists
        hl(0, 'MarkviewListItemMinus', { fg = p.subtle })
        hl(0, 'MarkviewListItemPlus', { fg = p.subtle })
        hl(0, 'MarkviewListItemStar', { fg = p.subtle })

        -- Tables
        hl(0, 'MarkviewTableHeader', { fg = p.foam, bold = true })
        hl(0, 'MarkviewTableBorder', { fg = p.muted })


        vim.keymap.set('n', '<leader>tm', '<cmd>Markview toggle<cr>', { desc = 'Toggle Markdown Rendering'})

        -- Vertical bar in sign column for each line of a fenced code block
        local ns = vim.api.nvim_create_namespace('md_code_bar')
        local query = vim.treesitter.query.parse('markdown', '(fenced_code_block) @b')
        vim.api.nvim_create_autocmd({ 'BufEnter', 'TextChanged', 'TextChangedI' }, {
            callback = function(ev)
                if vim.bo[ev.buf].filetype ~= 'markdown' then return end
                vim.api.nvim_buf_clear_namespace(ev.buf, ns, 0, -1)
                local ok, parser = pcall(vim.treesitter.get_parser, ev.buf, 'markdown')
                if not ok or not parser then return end
                local tree = parser:parse()[1]
                local mini_ok, mini_icons = pcall(require, 'mini.icons')
                for _, node in query:iter_captures(tree:root(), ev.buf) do
                    local srow, _, erow, _ = node:range()
                    -- Hide the opening and closing fence rows
                    vim.api.nvim_buf_set_extmark(ev.buf, ns, srow, 0, { conceal_lines = '' })
                    vim.api.nvim_buf_set_extmark(ev.buf, ns, erow - 1, 0, { conceal_lines = '' })

                    -- Extract language from (info_string (language))
                    local lang
                    for child in node:iter_children() do
                        if child:type() == 'info_string' then
                            for gc in child:iter_children() do
                                if gc:type() == 'language' then
                                    lang = vim.treesitter.get_node_text(gc, ev.buf)
                                end
                            end
                        end
                    end

                    local icon_text, icon_hl
                    if mini_ok and lang then
                        icon_text, icon_hl = mini_icons.get('filetype', lang)
                    end

                    for row = srow + 1, erow - 2 do
                        local is_first = row == srow + 1
                        vim.api.nvim_buf_set_extmark(ev.buf, ns, row, 0, {
                            sign_text = (is_first and icon_text) or '▎',
                            sign_hl_group = (is_first and icon_hl) or 'MarkviewCodeSign',
                        })
                    end
                end
            end,
        })
    end,
}
