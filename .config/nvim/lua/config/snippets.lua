print 'snippets loaded'
local ls = require 'luasnip'

ls.add_snippets('python', {
  ls.parser.parse_snippet('main', 'import pandas as pd\n\ndef main():\n\t${1:}\n\treturn\n\nif __name__ == "__main__":\n\tmain()'),
})
