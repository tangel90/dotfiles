vim.opt.clipboard = 'unnamedplus'
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
}
