% Ruff(ak) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2025-02-21

# Ruff Cheatsheet

Ruff is an extremely fast Python linter and formatter written in Rust.

------------------------------------------------------------------------

# 🧹 Formatter (`ruff format`)

`ruff format` Formats all supported Python files in the current
directory recursively (like Black).

`ruff format path/to/file.py` Formats a single file.

`ruff format path/to/dir` Formats all Python files inside a specific
directory.

`ruff format --check .` Checks formatting without modifying files; exits
non-zero if changes are needed (CI-friendly).

`ruff format --diff .` Shows a unified diff of formatting changes
without writing them.

`ruff format --config pyproject.toml .` Uses a specific configuration
file.

`ruff format --line-length 100 .` Overrides configured line length for
this run.

`ruff format --watch .` Continuously format files when they change.

------------------------------------------------------------------------

# 🔍 Linter (`ruff check`)

> Note: `ruff lint` was renamed to `ruff check`. Use `ruff check` in
> modern versions.

`ruff check .` Lints all Python files recursively in the current
directory.

`ruff check path/to/file.py` Lints a single file.

`ruff check --fix .` Automatically fixes safe lint violations.

`ruff check --unsafe-fixes .` Applies fixes that may change behavior
(use carefully).

`ruff check --diff .` Shows fixes as a diff without modifying files.

`ruff check --fix-only .` Applies fixes but does not report remaining
violations.

`ruff check --select E,F .` Only enable specific rule codes (e.g.,
Pycodestyle + Pyflakes).

`ruff check --ignore E501 .` Ignore specific rule codes.

`ruff check --extend-select B,I .` Add additional rule families (e.g.,
flake8-bugbear, isort rules).

`ruff check --per-file-ignores "tests/*:S101,E501,F401"` Ignore specific
rules for certain file patterns.

`ruff check --statistics .` Show aggregated statistics about violations.

`ruff check --show-fixes .` Display which fixes were applied.

`ruff check --output-format json .` Output lint results in
machine-readable JSON format.

`ruff check --watch .` Continuously lint files and re-run whenever a
file changes.

`ruff check --watch --fix .` Auto-fix issues on every file change.

------------------------------------------------------------------------

# ⚙️ Project Setup

`ruff --version` Displays installed Ruff version.

`ruff rule` Lists all supported lint rules.

`ruff rule E501` Shows detailed documentation for a specific rule.

`ruff config` Lists available configuration options.

`ruff clean` Clears Ruff's cache.

------------------------------------------------------------------------

# 📦 Common pyproject.toml Config Example

``` toml
[tool.ruff]
line-length = 100
target-version = "py311"

[tool.ruff.lint]
select = ["E", "F", "B", "I"]
ignore = ["E501"]

[tool.ruff.format]
quote-style = "double"
indent-style = "space"
```
