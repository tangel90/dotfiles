print 'snippets loaded'
local ls = require 'luasnip'

ls.Snippets = {
  python = {
    ls.parser.parse_snippet('main', 'if __name__ == "__main__":\n\t${1:main}()'),
  },
}
