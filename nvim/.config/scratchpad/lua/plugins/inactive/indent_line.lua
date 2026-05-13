return {
    { -- Add indentation guides even on blank lines
        'lukas-reineke/indent-blankline.nvim',
        -- Enable `lukas-reineke/indent-blankline.nvim`
        -- See `:help ibl`
        main = 'ibl',
        opts = {
            scope = {
                enabled = true,
                show_start = true,
                show_end = false,
                injected_languages = false,
                highlight = { 'Function', 'Label' },
                priority = 500,
            },
        },
    },
}
