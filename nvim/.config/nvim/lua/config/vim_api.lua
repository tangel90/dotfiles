-- let python docstrings be comments instead of screaming-loud-multiline-strings
vim.api.nvim_set_hl(0, '@string.documentation', { link = 'Comment' })
-- this tramples over injections (e.g. printf/sql/...) across many langs: unlink it
vim.api.nvim_set_hl(0, '@lsp.type.string', {})
-- unlink overly generic tokens from basedpyright that undo treesitter
vim.api.nvim_set_hl(0, '@lsp.type.variable.python', {})
vim.api.nvim_set_hl(0, '@lsp.type.class.python', {})

-- now actually put LSP to use:
-- let LSP indicate property type
vim.api.nvim_set_hl(0, '@lsp.type.property', { link = '@property' })
vim.api.nvim_set_hl(0, '@lsp.type.enumMember', { link = '@property' })
-- let LSP indicate parameters
vim.api.nvim_set_hl(0, '@lsp.type.parameter', { fg = 'NvimLightYellow' })
vim.api.nvim_set_hl(0, '@lsp.type.typeParameter', { fg = 'NvimLightYellow' })
-- let LSP indicate builtins
vim.api.nvim_set_hl(0, '@lsp.typemod.variable.defaultLibrary', { link = '@variable.builtin' })
vim.api.nvim_set_hl(0, '@lsp.typemod.function.defaultLibrary', { link = '@function.builtin' })
-- let LSP indicate statics
vim.api.nvim_set_hl(0, '@lsp.typemod.enumMember.static', { link = '@constant' })
vim.api.nvim_set_hl(0, '@lsp.typemod.method.static', { link = '@constant' })
vim.api.nvim_set_hl(0, '@lsp.typemod.property.static', { link = '@constant' })
vim.api.nvim_set_hl(0, '@lsp.typemod.variable.readonly.python', { link = '@constant' })
