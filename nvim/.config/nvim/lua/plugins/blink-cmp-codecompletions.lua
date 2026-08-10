-- Autocompletion via blink.cmp (migrated from nvim-cmp).
return {
  'saghen/blink.cmp',
  event = 'InsertEnter',
  version = '*',
  build = 'cargo build --release',
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
  opts = function()
    -- The Snowflake catalog source is optional and machine-specific; only
    -- wire it up when the module is actually installed.
    local has_snowflake = pcall(require, 'blink_sources.snowflake_catalog')

    local default_sources = { 'lsp', 'path', 'snippets', 'buffer' }
    local providers = {
      buffer = { min_keyword_length = 3 },
      snippets = { min_keyword_length = 2 },
    }
    if has_snowflake then
      table.insert(default_sources, 1, 'snowflake')
      providers.snowflake = {
        name = 'Snowflake',
        module = 'blink_sources.snowflake_catalog',
        score_offset = 100,
      }
    end

    return {
      keymap = {
        preset = 'none',
        -- <Tab> does three jobs, in priority order:
        --   1. jump to the next snippet placeholder, if a snippet is active
        --   2. cycle to the next item, if the menu is already open
        --   3. open the menu — e.g. after `SELECT * FROM ` where there is no
        --      keyword to trigger on, so the snowflake source lists tables
        -- Only when the cursor sits in leading whitespace does it fall back to
        -- a literal tab, so indenting still works. Accept stays on <CR>/<C-y>:
        -- if <Tab> both cycled and accepted, the first press would commit the
        -- preselected item instead of moving off it.
        ['<Tab>'] = {
          function(cmp)
            if cmp.snippet_active { direction = 1 } then
              return cmp.snippet_forward()
            end
            if cmp.is_menu_visible() then
              return cmp.select_next()
            end
            local col = vim.fn.col '.' - 1
            if col == 0 or vim.api.nvim_get_current_line():sub(1, col):match '^%s*$' then
              return false -- indent instead
            end
            return cmp.show()
          end,
          'fallback',
        },
        ['<S-Tab>'] = {
          function(cmp)
            if cmp.snippet_active { direction = -1 } then
              return cmp.snippet_backward()
            end
            if cmp.is_menu_visible() then
              return cmp.select_prev()
            end
            return false
          end,
          'fallback',
        },
        ['<C-n>'] = { 'select_next', 'show' },
        ['<C-p>'] = { 'select_prev', 'show' },
        ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },

      snippets = { preset = 'luasnip' },

      sources = {
        default = default_sources,
        providers = providers,
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
    }
  end,
}
