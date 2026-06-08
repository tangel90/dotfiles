-- Autocompletion via blink.cmp (migrated from nvim-cmp).
return {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '*',
    dependencies = {
        {
            'L3MON4D3/LuaSnip',
            build = (function()
                if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
                    return
                end
                return 'make install_jsregexp'
            end)(),
        },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
        keymap = {
            preset = 'none',
            ['<Tab>'] = {
                function(cmp)
                    -- if menu is open with 1 item, accept it
                    if cmp.is_visible() and #require('blink.cmp.completion.list').items == 1 then
                        return cmp.select_and_accept()
                    end
                    -- otherwise: trigger show only when the cursor is after
                    -- non-whitespace content (i.e. likely a completion context,
                    -- not start-of-line indentation).
                    local col = vim.fn.col('.') - 1
                    if col > 0 then
                        local prev = vim.fn.getline('.'):sub(col, col)
                        if not prev:match('%s') then
                            return cmp.show()
                        end
                        -- prev char is whitespace — show only if the char before
                        -- that is an identifier/keyword character (after `FROM ` etc.)
                        if col > 1 then
                            local prev2 = vim.fn.getline('.'):sub(col - 1, col - 1)
                            if prev2:match('[%w_]') then
                                return cmp.show()
                            end
                        end
                    end
                end,
                'select_next',
                'fallback',
            },
            ['<S-Tab>'] = { 'select_prev', 'fallback' },
            ['<C-n>'] = { 'select_next', 'show' },
            ['<C-p>'] = { 'select_prev', 'show' },
            ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
            ['<C-y>'] = { 'select_and_accept' },
            ['<CR>'] = { 'accept', 'fallback' },
            -- ['<Tab>'] = { 'select_and_accept', 'fallback' },
            ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
            -- ['<S-Tab>'] = { 'snippet_forward', 'fallback' },
            ['<C-Tab>'] = { 'snippet_backward', 'fallback' },
        },

        snippets = { preset = 'luasnip' },

        sources = {
            default = { 'snowflake', 'lsp', 'path', 'snippets', 'buffer' },
            providers = {
                buffer = { min_keyword_length = 3 },
                snippets = { min_keyword_length = 2 },
                snowflake = {
                    name = 'Snowflake',
                    module = 'blink_sources.snowflake_catalog',
                    score_offset = 100,
                },
            },
        },

        completion = {
            list = { selection = { preselect = true, auto_insert = false } },
            menu = { border = 'rounded' },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
                window = { border = 'rounded' },
            },
        },

        signature = { enabled = true, window = { border = 'rounded' } },

        fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
}
