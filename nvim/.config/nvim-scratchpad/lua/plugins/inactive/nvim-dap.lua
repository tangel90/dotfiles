-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'mfussenegger/nvim-dap-python',
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    dap.configurations.python = {
      {
        type = 'python',
        request = 'launch',
        name = 'Launch file (/usr/bin/python3)',
        program = '${file}',
        pythonPath = function()
          return '/usr/sbin/python3'
        end,
      },
      {
        type = 'python',
        request = 'launch',
        name = 'Launch main.py with Args (/usr/bin/python3)',
        program = 'main.py',
        args = function()
          local input = vim.fn.input 'Arguments: '
          return vim.split(input, ' ')
        end,
        console = 'integratedTerminal',
        pythonPath = function()
          return '/usr/sbin/python3'
        end,
      },
      {
        type = "python",
        request = "launch",
        name = "Launch file with conda (dev)",
        program = "${file}",
        pythonPath = function()
          return "/home/thomas/.conda/envs/dev/bin/python3"
        end,
      }
    }
    -- Configure the CoreCLR adapter
    dap.adapters.coreclr = {
      type = 'executable',
      command = 'netcoredbg', -- Ensure netcoredbg is in your PATH
      args = { '--interpreter=vscode' },
    }

    -- Common configuration for .NET projects
    local common_config = {
      type = 'coreclr',
      request = 'launch',
      name = 'Launch .NET Core App',
      cwd = '${workspaceFolder}',
      stopAtEntry = false,
      args = {}, -- To be filled per project
      env = {}, -- To be filled per project
    }

    -- Configuration for Etl
    local etl_config = vim.tbl_deep_extend('force', common_config, {
      name = 'Launch Etl',
      program = '${workspaceFolder}/bin/Debug/net8.0/Etl.dll', -- Update net7.0 if different
      args = {}, -- Add arguments if needed
      env = {
        DOTNET_ENVIRONMENT = 'Development',
      },
    })

    -- Assign the Etl configuration
    dap.configurations.cs = dap.configurations.cs or {}
    table.insert(dap.configurations.cs, etl_config)

    -- Optional: Configuration for Etl.Client (if applicable)
    local etl_client_config = vim.tbl_deep_extend('force', common_config, {
      name = 'Launch Etl.Client',
      program = '${workspaceFolder}/bin/Debug/net8.0/EMCDRETL.dll', -- Use .exe if available
      args = { 'etl', '--project', 'CARDIO_TEST_TS', '--processType', 'Subjects' },
      env = {
        -- Add environment variables if needed
      },
    })

    table.insert(dap.configurations.cs, etl_client_config)
    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })
    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
    }

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup {
      delve = {
        -- On Windows delve must be run attached or it crashes.
        -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
        detached = vim.fn.has 'win32' == 0,
      },
    }
  end,
}
