return {
  'nvim-lualine/lualine.nvim',
  opts = {
    winbar = {
      lualine_c = {
        {
          function()
            return require('nvim-navic').get_location()
          end,
          cond = function()
            return package.loaded['nvim-navic'] and require('nvim-navic').is_available()
          end,
        },
      },
    },
  },
}
