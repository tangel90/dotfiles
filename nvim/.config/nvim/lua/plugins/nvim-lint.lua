-- sqlfluff with dbt templater is a project-level tool (compiles the full dbt
-- DAG before linting) and is not suitable for per-buffer editor diagnostics.
-- SQL validation is handled via EXPLAIN pre-flight in keymaps.lua (<leader>rp).
-- Run sqlfluff manually from the project root when needed:
--   sqlfluff lint models/my_model.sql
return {}
