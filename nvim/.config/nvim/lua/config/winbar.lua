-- Treesitter breadcrumb in the winbar.
--
-- Replaces nvim-treesitter-context, which drew the same information into a
-- floating window. That float was the single biggest source of editing lag:
-- while a float overlays a window, nvim's TUI cannot emit a small delta for a
-- cursor move. Measured on a 100x30 terminal, per `j` keypress:
--
--   no float / winbar ......  2,413 B      float (treesitter-context) .. 13,568 B
--   static winbar ..........  2,545 B      dumb static float ........... 13,208 B
--
-- The dumb float held one hardcoded line and never updated, so the cost is the
-- float itself, not treesitter: computing the context takes 0.019 ms. winbar
-- draws in the window grid, so the incremental redraw keeps working.
--
-- Neither nvim core (0.12) nor nvim-treesitter's main branch ships a sticky
-- context: core offers only the drawing surfaces ('winbar', 'statusline') plus
-- vim.treesitter.get_node(), and the old nvim-treesitter statusline() helper
-- was deleted in the rewrite. Hence assembling it here.

local M = {}

-- Node types that count as a nameable scope, keyed by treesitter language (not
-- filetype). Only languages listed here get a winbar at all, so unrelated
-- buffers do not lose a screen line to an empty bar.
local scopes = {
  python = { class_definition = true, function_definition = true },
  lua = { function_declaration = true, function_definition = true },
  go = { function_declaration = true, method_declaration = true, type_spec = true },
  javascript = { class_declaration = true, function_declaration = true, method_definition = true },
  typescript = { class_declaration = true, function_declaration = true, method_definition = true, interface_declaration = true },
  rust = { function_item = true, impl_item = true, struct_item = true, trait_item = true },
  c = { function_definition = true, struct_specifier = true },
}

local SEP = ' › '
local MAX_CRUMBS = 4

--- Best-effort name for a scope node.
--- `name` covers python/go/js/rust; c puts it in `declarator`; anything else
--- falls back to the node's own first line, trimmed.
local function label(node, buf)
  for _, field in ipairs { 'name', 'declarator' } do
    local n = node:field(field)[1]
    if n then
      local text = vim.treesitter.get_node_text(n, buf)
      if text and text ~= '' then
        return (text:gsub('%s*%b()%s*$', ''):gsub('^%s+', ''))
      end
    end
  end
  local row = node:range()
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1] or ''
  return (line:gsub('^%s+', ''):sub(1, 40))
end

local cache = { key = nil, value = '' }

--- Breadcrumb for the window being drawn, outermost scope first.
function M.render()
  -- 'winbar' is evaluated once per window, not for the current one, so take the
  -- window from g:statusline_winid; nvim_get_current_win() would report the
  -- wrong buffer and cursor in a split.
  local win = tonumber(vim.g.statusline_winid) or vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(win) then
    return ''
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local lang = vim.treesitter.language.get_lang(vim.bo[buf].filetype)
  local want = lang and scopes[lang]
  if not want then
    return ''
  end

  -- winbar is re-evaluated on every redraw, so memoise per cursor line
  local pos = vim.api.nvim_win_get_cursor(win)
  local key = table.concat({ win, buf, vim.api.nvim_buf_get_changedtick(buf), pos[1] }, ':')
  if cache.key == key then
    return cache.value
  end

  -- get_node() returns nil while the tree is unparsed, and config.autocmds only
  -- calls vim.treesitter.start() for a few filetypes, so parse explicitly. This
  -- is incremental and a no-op once the tree is current.
  local okp, parser = pcall(vim.treesitter.get_parser, buf)
  if not okp or not parser then
    return ''
  end
  pcall(parser.parse, parser)

  local crumbs = {}
  local ok, node = pcall(vim.treesitter.get_node, { bufnr = buf, pos = { pos[1] - 1, pos[2] } })
  while ok and node do
    if want[node:type()] then
      table.insert(crumbs, 1, label(node, buf))
    end
    node = node:parent()
  end

  while #crumbs > MAX_CRUMBS do
    table.remove(crumbs, 1)
  end

  cache.key = key
  cache.value = #crumbs > 0 and ('%#WinBar#' .. table.concat(crumbs, SEP)) or ''
  return cache.value
end

--- Windows that should carry the bar: real files only, never floats, never the
--- bigfile filetype (see config.autocmds — those buffers deliberately run bare).
local function eligible(win, buf)
  if vim.api.nvim_win_get_config(win).relative ~= '' then
    return false
  end
  if vim.bo[buf].buftype ~= '' then
    return false
  end
  local ft = vim.bo[buf].filetype
  if ft == '' or ft == 'bigfile' then
    return false
  end
  local lang = vim.treesitter.language.get_lang(ft)
  return lang ~= nil and scopes[lang] ~= nil
end

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'WinEnter', 'FileType' }, {
  group = vim.api.nvim_create_augroup('ts-winbar', { clear = true }),
  callback = function(ev)
    local win = vim.api.nvim_get_current_win()
    if vim.api.nvim_win_get_buf(win) ~= ev.buf then
      return
    end
    vim.wo[win].winbar = eligible(win, ev.buf) and '%<%{%v:lua.require("config.winbar").render()%}' or ''
  end,
})

return M
