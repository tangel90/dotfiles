local plugins = {}

vim.list_extend(plugins, require("plugins.nvchad"))
vim.list_extend(plugins, require("plugins.lspconfig"))
vim.list_extend(plugins, require("plugins.lazygit"))
vim.list_extend(plugins, require("plugins.mason"))
vim.list_extend(plugins, require("plugins.treesitter"))
vim.list_extend(plugins, require("plugins.conform"))

return plugins
