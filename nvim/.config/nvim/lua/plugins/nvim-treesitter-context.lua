return {
    'nvim-treesitter/nvim-treesitter-context',
    opts = {
        enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
        multiwindow = false, -- Enable multiwindow support.
        min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
        line_numbers = true,
        multiline_threshold = 20, -- Maximum number of lines to show for a single context
        -- 'outer' discards the OUTERMOST lines when max_lines is exceeded, i.e.
        -- exactly the `class`/`def` lines wanted. Inside class > def > if > for it
        -- kept only `if`/`for`; 'inner' keeps class/def and drops the block lines.
        trim_scope = 'inner', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
        mode = 'cursor', -- Line used to calculate context. Choices: 'cursor', 'topline'
        -- Separator between context and content. Should be a single character string, like '-'.
        -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
        separator = nil,
        zindex = 20, -- The Z-index of the context window
        on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
        max_lines = 4, -- 2 could not fit class + def together with any nesting
    },
    config = function(_, opts)
      require('treesitter-context').setup(opts)
      vim.keymap.set('n', '[c',function() require('treesitter-context').go_to_context(vim.v.count1) end)
    end,
}
