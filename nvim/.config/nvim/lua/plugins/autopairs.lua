-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- With blink.cmp we drop the cmp-event integration; blink handles bracket
  -- pairing on accept through its own keymap layer, and autopairs still does
  -- the right thing in regular insert mode.
  config = function()
    require('nvim-autopairs').setup {}
  end,
}
