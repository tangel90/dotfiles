return {
    'OXY2DEV/markview.nvim',
    lazy = false,

    -- Completion for `blink.cmp`
    dependencies = { 'saghen/blink.cmp' },
    config = function()
        local opts = {}

        opts.preview = {
            modes = { 'n', 'i', 'c' },
            -- hybrid_modes = { 'n', 'i' }, # this will disable preview only for blocks under cursor
            ignore_previews = {
                markdown = { '!code_blocks', '!block_quote', '!headings' },
                markdown_inline = { 'inline_codes' },
            },
            icon_provider = 'mini',
            --     debounce = 0,
        }

        -- opts.preview.callbacks = {
        -- 	on_enable = function(_, wins)
        -- 		for _, win in ipairs(wins) do
        -- 			vim.wo[win].conceallevel = 3
        -- 			-- vim.wo[win].concealcursor = "n,v"
        -- 			-- vim.wo[win].linebreak = true
        -- 		end
        -- 	end
        -- }

        opts.markdown = {}

        opts.markdown.code_blocks = {
            enable = true,

            border_hl = 'MarkviewCode',
            info_hl = 'MarkviewCodeInfo',

            label_direction = 'right',
            label_hl = nil,

            min_width = 60,
            pad_amount = 2,
            pad_char = ' ',

            default = {
                block_hl = 'MarkviewCode',
                pad_hl = 'MarkviewCode',
            },

            ['diff'] = {
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

        -- opts.markdown.headings = {
        --     heading_1 = { style = 'icon' },
        --     heading_2 = { style = 'icon' },
        --     heading_3 = { style = 'icon' },
        --     heading_4 = { style = 'icon' },
        --     heading_5 = { style = 'icon' },
        --     heading_6 = { style = 'icon' },
        --     setext_1 = { sign = '', icon = ' ' },
        --     setext_2 = { sign = '', icon = ' ' },
        -- }

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
    end,
}
