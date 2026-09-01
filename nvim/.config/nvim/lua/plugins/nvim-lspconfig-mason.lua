return { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    dependencies = {
        -- Automatically install LSPs and related tools to stdpath for Neovim
        { 'williamboman/mason.nvim', config = true }, -- NOTE: Must be loaded before dependants
        'williamboman/mason-lspconfig.nvim',
        'WhoIsSethDaniel/mason-tool-installer.nvim',

        -- Useful status updates for LSP.
        -- Default spinner + 10Hz notification redraws read as cursor flicker
        -- during initial LSP indexing (pyright/etc). Static icon + slower
        -- redraw keeps the progress messages without the flicker.
        {
            'j-hui/fidget.nvim',
            opts = {
                progress = { display = { progress_icon = { pattern = 'dots', period = 1e9 } } },
                notification = { poll_rate = 3 },
            },
        },

        -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
        -- used for completion, annotations and signatures of Neovim apis
        -- { 'folke/neodev.nvim', opts = {} }, -- not needed when lazydev.nvim is installed
    },
    config = function()
        -- If you're wondering about lsp vs treesitter, you can check out the wonderfully
        -- and elegantly composed help section, `:help lsp-vs-treesitter`

        -- vim.lsp.config is the new way to config lsp since Neovim 0.11
        vim.lsp.config('lua_ls', {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { 'vim' },
                    },
                    format = {
                        enable = true,
                        indent_style = 'space',
                        indent_size = '4',
                    },
                },
            },
        })
        vim.lsp.config('ruff', {
            init_options = {
                settings = {
                    -- Ruff language server settings go here
                    logLevel = 'debug',
                },
            },
        })

        vim.lsp.enable 'ruff'

        vim.diagnostic.config {
            virtual_text = {
                severity = { min = vim.diagnostic.severity.WARN },
                format = function(diagnostic)
                    local first_line = diagnostic.message:gmatch '[^\n]*'()
                    local first_sentence = string.match(first_line, '(.-%. )') or first_line
                    local first_lhs = string.match(first_sentence, '(.-): ') or first_sentence
                    return first_lhs
                end,
            },
            underline = { severity = { min = vim.diagnostic.severity.WARN } },
            signs = { severity = { min = vim.diagnostic.severity.WARN } },
        }

        vim.api.nvim_create_autocmd('LspAttach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
            callback = function(event)
                -- NOTE: Remember that Lua is a real programming language, and as such it is possible
                -- to define small helper and utility functions so you don't have to repeat yourself.
                --
                -- In this case, we create a function that lets us more easily define mappings specific
                -- for LSP related items. It sets the mode, buffer and description for us each time.
                local map = function(keys, func, desc)
                    vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
                end

                -- Jump to the definition of the word under your cursor.
                --  This is where a variable was first declared, or where a function is defined, etc.
                --  To jump back, press <C-t>.
                map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
                -- WARN: This is not Goto Definition, this is Goto Declaration.
                --  For example, in C this would take you to the header.
                map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
                map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
                -- Jump to the implementation of the word under your cursor.
                --  Useful when your language has ways of declaring types without an actual implementation.
                map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')
                -- Jump to the type of the word under your cursor.
                --  Useful when you're not sure what type a variable is and you want to see
                --  the definition of its *type*, not where it was *defined*.
                map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')
                map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
                map('<leader>ld', require('telescope.builtin').lsp_document_symbols, '[Lsp] [D]ocument Symbols')
                map('<leader>lw', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[Lsp] [W]orkspace Symbols')

                -- map('<leader>wa', vim.lsp.buf.add_workspace_folder(), '[W]orkspace: [A]dd Folder')
                -- map('<leader>wr', vim.lsp.buf.remove_workspace_folder(), '[W]orkspace: [R]emove Folder')
                -- map('<leader>wl', print(vim.inspect(vim.lsp.buf.list_workspace_folders())), '[W]orkspace: [L]ist Folders')

                -- Execute a code action, usually your cursor needs to be on top of an error
                -- or a suggestion from your LSP for this to activate.
                map('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

                -- Opens a popup that displays documentation about the word under your cursor
                --  See `:help K` for why this keymap.
                map('<leader>h', vim.lsp.buf.hover, '[H]over Documentation')

                -- Reference highlighting is on <leader>lh rather than on CursorHold.
                --
                -- Kickstart wires document_highlight to CursorHold and
                -- clear_references to CursorMoved. With updatetime=250 that
                -- repainted the word under the cursor a quarter second after
                -- every pause, which reads as the cursor flickering while you
                -- sit still. It only showed up in repos whose server advertises
                -- documentHighlightProvider — noisy in python (pyright), absent
                -- in the dbt/iac repos, where sqls does not offer it.
                local client = vim.lsp.get_client_by_id(event.data.client_id)
                if client and client.server_capabilities.documentHighlightProvider then
                    map('<leader>lh', function()
                        -- Toggle: highlight on first press, clear on the next.
                        if vim.b.lsp_refs_shown then
                            vim.lsp.buf.clear_references()
                            vim.b.lsp_refs_shown = false
                        else
                            vim.lsp.buf.document_highlight()
                            vim.b.lsp_refs_shown = true
                        end
                    end, '[L]sp [H]ighlight references')

                    vim.api.nvim_create_autocmd('LspDetach', {
                        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
                        callback = function()
                            vim.lsp.buf.clear_references()
                        end,
                    })
                end

                -- The following autocommand is used to enable inlay hints in your
                -- code, if the language server you are using supports them
                --
                -- This may be unwanted, since they displace some of your code
                -- if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
                --   map('<leader>th', function()
                --     vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
                --   end, '[T]oggle Inlay [H]ints')
                -- end
            end,
        })

        -- blink.cmp registers its enhanced LSP capabilities into vim.lsp.config
        -- automatically on load, so a manual require + extend is no longer needed.mason
        local capabilities = vim.lsp.protocol.make_client_capabilities()

        -- sqls talks to whatever connection its config lists first, so with a
        -- static ~/.config/sqls/config.yml the completion always came from one
        -- fixed database. The per-directory .envrc files already declare the
        -- right one via PGSERVICE (direnv exports it, and nvim inherits it when
        -- the sessionizer starts nvim in that directory), so derive the
        -- connection from that instead.
        --
        -- Fallbacks, in order:
        --   * PGSERVICE unset            -> no `settings` sent, so sqls keeps
        --                                   reading ~/.config/sqls/config.yml
        --                                   exactly as before.
        --   * PGSERVICE not in the       -> same fallback, plus a warning. A
        --     service file                  name with no [section] can never
        --                                   connect, so it is not worth sending.
        --   * service exists but the     -> sent anyway; sqls starts fine and
        --     database is unreachable       keyword completion still works, only
        --                                   schema completion is missing. Cannot
        --                                   be detected without connecting.
        local function sqls_settings()
            local service = vim.env.PGSERVICE
            if not service or service == '' then
                return nil
            end

            -- readfile + filereadable rather than io.lines: a missing service
            -- file makes io.lines raise, and this runs inside the plugin spec,
            -- so it would take the whole LSP setup down with it.
            local service_file = vim.env.PGSERVICEFILE or (vim.env.HOME .. '/.pg_service.conf')
            local defined = false
            if vim.fn.filereadable(service_file) == 1 then
                for _, line in ipairs(vim.fn.readfile(service_file)) do
                    if line:match('^%s*%[' .. vim.pesc(service) .. '%]') then
                        defined = true
                        break
                    end
                end
            end
            if not defined then
                vim.notify(("sqls: PGSERVICE=%s is not defined in %s; using config.yml"):format(service, service_file), vim.log.levels.WARN)
                return nil
            end

            return {
                sqls = {
                    connections = {
                        { driver = 'postgresql', dataSourceName = 'service=' .. service },
                    },
                },
            }
        end

        --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
        local servers = {
            -- clangd = {},
            marksman = {
                lineLength = 120,
                -- marksman's fileOperations filters produce an invalid glob (**/*.{})
                -- in mini.files' LSP hook — drop the capability so it isn't consulted
                on_init = function(client)
                    client.server_capabilities.workspace = client.server_capabilities.workspace or {}
                    client.server_capabilities.workspace.fileOperations = nil
                end,
            },
            gopls = {
                cmd = { 'gopls' },
                filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
                settings = {
                    gopls = {
                        completeUnimported = true,
                        usePlaceholders = true,
                        analyses = {
                            unusedparams = true,
                        },
                    },
                },
            },
            jqls = {
                filetypes = { 'json', 'jq' },
            },
            python = {
                analysis = {
                    -- Ignore all files for analysis to exclusively use Ruff for linting
                    ignore = { '*' },
                },
            },
            pyright = {
                settings = {
                    pyright = {
                        analysis = {
                            disableOrganizeImports = true,
                            autoSearchPaths = true,
                            diagnosticMode = 'openFilesOnly',
                            useLibraryCodeForTypes = true,
                            reportMissingTypeStubs = false,
                            typeCheckingMode = 'basic',
                        },
                    },
                },
            },
            sqls = { settings = sqls_settings() },
            rust_analyzer = {},
            -- ... etc. See `:help lspconfig-all` for a list of all the pre-configured LSPs
            --
            -- Some languages (like typescript) have entire language plugins that can be useful:
            --    https://github.com/pmizio/typescript-tools.nvim
            --
            -- But for many setups, the LSP (`tsserver`) will work just fine
            -- tsserver = {},
            omnisharp = {
                filetypes = { 'cs', 'csx' },
                -- cmd = { 'dotnet' },

                settings = {
                    FormattingOptions = {
                        -- Enables support for reading code style, naming convention and analyzer
                        -- settings from .editorconfig.
                        EnableEditorConfigSupport = true,
                        -- Specifies whether 'using' directives should be grouped and sorted during
                        -- document formatting.
                        OrganizeImports = nil,
                    },
                    MsBuild = {
                        -- If true, MSBuild project system will only load projects for files that
                        -- were opened in the editor. This setting is useful for big C# codebases
                        -- and allows for faster initialization of code navigation features only
                        -- for projects that are relevant to code that is being edited. With this
                        -- setting enabled OmniSharp may load fewer projects and may thus display
                        -- incomplete reference lists for symbols.
                        LoadProjectsOnDemand = nil,
                    },
                    RoslynExtensionsOptions = {
                        -- Enables support for roslyn analyzers, code fixes and rulesets.
                        EnableAnalyzersSupport = nil,
                        -- Enables support for showing unimported types and unimported extension
                        -- methods in completion lists. When committed, the appropriate using
                        -- directive will be added at the top of the current file. This option can
                        -- have a negative impact on initial completion responsiveness,
                        -- particularly for the first few completion sessions after opening a
                        -- solution.
                        EnableImportCompletion = nil,
                        -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
                        -- true
                        AnalyzeOpenDocumentsOnly = nil,
                    },
                    Sdk = {
                        -- Specifies whether to include preview versions of the .NET SDK when
                        -- determining which version to use for project loading.
                        IncludePrereleases = true,
                    },
                },
                keys = {
                    {
                        'gd',
                        function()
                            require('omnisharp_extended').telescope_lsp_definitions()
                        end,
                        desc = 'Goto Definition',
                    },
                },
                enable_roslyn_analyzers = true,
                organize_imports_on_format = true,
                enable_import_completion = true,
            },
        }

        require('mason').setup()

        local ensure_installed = vim.tbl_keys(servers or {})
        vim.list_extend(ensure_installed, {
            'stylua', -- Used to format Lua code
            -- 'black', -- Used to format python code
            'ruff', -- Used to format python code
            'jqls',
            'prettier', -- cli formatter
            'prettierd', -- daemon version of prettier (means it runs in the background and thus has better performance)
            'ast-grep',
            -- 'csharpier',
            'pyright',
            'lua-language-server',
            'sql-formatter',
            'debugpy',
            'marksman',
            'markdownlint-cli2',
            'markdown-toc',
            -- 'netcoredbg',
        })
        require('mason-tool-installer').setup { ensure_installed = ensure_installed }

        require('mason-lspconfig').setup {
            handlers = {
                function(server_name)
                    local server = servers[server_name] or {}
                    -- This handles overriding only values explicitly passed
                    -- by the server configuration above. Useful when disabling
                    -- certain features of an LSP (for example, turning off formatting for tsserver)
                    server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
                    require('lspconfig')[server_name].setup(server)
                end,
            },
        }
    end,
}
