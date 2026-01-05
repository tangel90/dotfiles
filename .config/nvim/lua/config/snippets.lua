local ls = require 'luasnip'

--- python
ls.add_snippets('python', {
  ls.parser.parse_snippet('new_pandas', 'import pandas as pd\n\ndef main():\n\t${1:}\n\treturn\n\nif __name__ == "__main__":\n\tmain()'),
})

ls.add_snippets('python', {
  ls.parser.parse_snippet('if_main', 'if __name__ == "__main__":\n\tmain()'),
})

--- go
ls.add_snippets('go', {
  ls.parser.parse_snippet('main', 'package main\n\nimport "fmt"\n\nfunc main(){\n\t${1:}\n}'),
})
