return {
    'rmagatti/auto-session',
    lazy = false,
    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
        suppressed_dirs = { '~/', '~/Downloads', '/', '~/data', '~/build', '~/.local' },
        -- log_level = 'debug',
    },
    config = function(_, opts)
      require('auto-session').setup(opts)
      vim.o.sessionoptions = "blank,folds,help,localoptions"-- Hide deprecation warnings
    end
}
