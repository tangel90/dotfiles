-- These are some examples, uncomment them if you want to see them work!
-- in order to modify the 'lspconfig' configuration
return {
  "neovim/nvim-lspconfig",
  config = function()
    require("nvchad.configs.lspconfig").defaults()
    require "configs.lspconfig"
  end,
}

