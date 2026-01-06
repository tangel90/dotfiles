return { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
        {
            '<leader>==',
            function()
                require('conform').format { async = true, lsp_fallback = true }
            end,
            mode = '',
            desc = 'Format buffer',
        },
    },
    opts = {
        notify_on_error = true,
        format_on_save = function(bufnr)
            -- Disable "format_on_save lsp_fallback" for languages that don't
            -- have a well standardized coding style. You can add additional
            -- languages here or re-enable it for the disabled ones.
            local disable_filetypes = { c = true, cpp = true }
            return {
                timeout_ms = 500,
                lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
            }
        end,
        formatters_by_ft = {
            lua = { 'stylua' },
            cs = { 'csharpier' },

            -- You can use a sub-list to tell conform to run *until* a formatter is found. DEPRECATED
            javascript = { 'prettierd' },
            typescript = { 'prettierd' },
            javascriptreact = { 'prettierd' },
            typescriptreact = { 'prettierd' },
            json = { 'prettierd' },

            -- Conform can also run multiple formatters sequentially
            python = { 'black' },

            svelte = { 'prettier' },
            css = { 'prettier' },
            html = { 'prettier' },
            yaml = { 'prettier' },
            markdown = { 'prettier' },
            graphql = { 'prettier' },
            liquid = { 'prettier' },
        },
        formatters = {
            black = {
                prepend_args = { '--line-length', '100' },
            },
            stylua = {
                prepend_args = {
                    '--column-width',
                    '120',
                    '--indent-width',
                    '4',
                    '--indent-type',
                    'Spaces',
                },
            },
            prettier = {
                extra_args = { '--tab-width', '4' },
            },
            prettierd = {
                extra_args = { '--tab-width', '4' },
            },
        },
    },
}
