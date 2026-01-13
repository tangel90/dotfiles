local ls = require 'luasnip'

--- python
ls.add_snippets('python', {
  ls.parser.parse_snippet('new_pandas', 'import pandas as pd\n\ndef main():\n\t${1:}\n\treturn\n\nif __name__ == "__main__":\n\tmain()'),
  ls.parser.parse_snippet('if_main', 'if __name__ == "__main__":\n\tmain()'),
})

ls.add_snippets('python', {
  ls.parser.parse_snippet('lw', 'logger.warning("${1:}")'),
  ls.parser.parse_snippet('lwf', 'logger.warning(f"${1:}")'),
  ls.parser.parse_snippet('le', 'logger.error("${1:}")'),
  ls.parser.parse_snippet('lef', 'logger.error(f"${1:}")'),
  ls.parser.parse_snippet('ld', 'logger.debug("${1:}")'),
  ls.parser.parse_snippet('ldf', 'logger.debug(f"${1:}")'),
  ls.parser.parse_snippet('li', 'logger.info("${1:}")'),
  ls.parser.parse_snippet('lif', 'logger.info(f"${1:}")'),
})

--- go
ls.add_snippets('go', {
  ls.parser.parse_snippet('main', 'package main\n\nimport "fmt"\n\nfunc main(){\n\t${1:}\n}'),
})
