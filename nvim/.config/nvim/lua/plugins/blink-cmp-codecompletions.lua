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
            ['<Tab>'] = { 'accept', 'fallback' },
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
