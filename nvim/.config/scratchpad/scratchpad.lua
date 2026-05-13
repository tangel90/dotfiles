vim.opt.runtimepath:prepend(vim.fn.expand('~/.config/nvim'))

require 'config.options'

require 'config.keymaps'

require 'lazy-bootstrap'

require 'lazy-plugins'

-- require 'config.snippets'
