% uv(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2025-08-15

# NAME

A custom man page for **uv**

# SYNOPSIS

# DESCRIPTION

A collection of useful uv commands

# uv interpreter/env selection (flow)

```
Start
 └─> Did you pass --python / --python-version ?
      ├─ Yes → use that interpreter (no project auto-create)
      └─ No
          └─ Is a venv already ACTIVE? (VIRTUAL_ENV or sys.prefix!=sys.base_prefix)
              ├─ Yes → use the active venv
              └─ No
                  └─ Are you in a project? (pyproject.toml or uv.lock in CWD/parents) [unless --no-project]
                      ├─ No (or --no-project)
                      │   └─ Is there a `.venv/` in CWD/parents?
                      │       ├─ Yes → use that `.venv`
                      │       └─ No  → use `python` from PATH (system/Conda/Homebrew/etc.)
                      └─ Yes (project mode)
                          └─ Is there a project env? (e.g., `.venv/` or configured location)
                              ├─ Yes → use it
                              └─ No  → create project env → use it
```

## notes & quick handles

* **Project mode** is on by default when a `pyproject.toml` or `uv.lock` is found up the tree. In that mode, `uv run` / `uv pip` will **ensure** a project env exists (creating it if missing) before running.
* If you just want to “peek” without triggering project env creation:
  `uv run --no-project python -m site`
* Force a specific interpreter (bypasses discovery):
  `uv run --python /path/to/python …`
  `uv pip install --python /path/to/python PKG`
* Use system interpreter intentionally:
  `uv pip install --system PKG`
* If a `.venv/` exists in the current or a parent directory, it’s preferred even without activation (outside project mode).
* On Windows, if you’re relying on PATH discovery, the `py` launcher’s default may influence which Python is picked.

### TLDR to above

* Project dir + no env → uv will create one for you.
* Non-project dir + no env → uv just uses the default Python in your `PATH`.
* Explicit `--python` → uv ignores auto-create and uses what you told it.

# COMMON OPTIONS

uv venv \[Path]
:   Create venv at a particular Path(`.venv` by default). Looks like you should be careful and create venv only at a root project folder first to avoid having multiple `.venv`s created for you.

`mkdir some_dir && cd some_dir && uv venv`
:   Note how this will create a venv in some_dir even if you already have a venv created in the parent dir! Not what you wanted, isn't it?

uv sync \[-\-inexact] ...
:   Syncing ensures that all project's dependencies are installed and up-to-date with the lockfile. `--inexact` forces uv to skip pruning step — so extra packages installed ad-hoc (via `uv pip install`, etc.) will stay, even though they’re not tracked in the project’s dependency list.

`uv sync --no-dev`
:   Install without dev dependencies

`uv sync [--dev]`
:   **Default option**. Install both main and dev dependencies

`uv sync --dry-run ...`
:   Visualize but do nothing

uv add *PackageName\[==version]* ...
:   Add packages to `pyproject.toml` file and you current venv

uv add \[-\-dev] ...
:   Add packages as a dev dependency

uv add --script script.py mlflow==2.0.0 ...
:   Update script.py, inserting a TOML-style metadata block at the top that declares the dependency. `uv run script.py` will automatically use it

`uv cache prune`
:   prune unreachable packages

`uv pip compile pyproject.toml -o requirements.txt`
:   produce `requirements.txt` for export based on `pyproject.toml`. Because of `pip-compile` nature, the file includes not just the direct dependencies that your code imports directly, but also versions for all of the transitive dependencies as well, that is, the versions of modules that your directly dependent modules themselves depend on. Essentially, this is a version of lock file that uses `pip-compile`

`uv pip install [--strict] ...`
:   Validate the Python environment after completing the installation, to detect packages with missing dependencies or other issues

`uv pip install [--dry-run] ...`
:   Self-explanatory

`uv pip install [--offline] ...`
:   Rely on uv cache, etc.

`uv pip list`
:   List all packages installed in the current venv

`uv tree`
:   View a dependency graph

`uv python find`
:   Determine which executable will be used

`uv run which python`
:   Should determine which python is used via `run` subcommand. Unsure?

`uv run python -c "import sys; print(sys.prefix)"`
:   Print path to currently used Python?

`uv python pin 3.12`
:   Create a file `.python-version` so that uv would only use that version

`uv export -o pylock.toml`
:   Export lock file using a new standardized `pylock.toml` format

## uv add

### Uv run Adding Resolution Order

```sql
                         ┌──────────────────────────┐
                         │        uv run            │
                         └─────────────┬────────────┘
                                       │
                ┌──────────────────────┼──────────────────────┐
                │                                             │
      ┌─────────▼─────────┐                          ┌────────▼─────────┐
      │   Inside Project  │                          │  Outside Project │
      │ (pyproject + venv)│                          │   (no pyproject) │
      └─────────┬─────────┘                          └────────┬─────────┘
                │                                             │
   ┌────────────┼─────────────┐                   ┌───────────┼───────────┐
   │            │             │                   │                       │
┌──▼──────────┐ ┌─────────────▼───────┐     ┌─────▼───────────┐   ┌───────▼─────────┐
│ uv run      │ │ uv run --with pkg   │     │ uv run [--with  │   │ PEP 723 script  │
│ script.py   │ │ ephemeral overlay   │     │ pkg1] pkg2 ...  │   │ inline deps     │
│ uses .venv  │ │ + access to .venv   │     │ isolated venv   │   │ isolated venv   │
│ (only!)     │ │ (no .venv change)   │     │ in cache dir    │   │ in cache dir    │
│ if no inline│ │ use --no-project to │     └─────────────────┘   └─────────────────┘
│ metadata.   │ │ ignore project venv │
└─────────────┘ └─────────────────────┘
                           │
                           │
               ┌───────────▼────────────┐
               │ PEP 723 inline deps    │
               │ on top of a script:    │
               │ - ignores .venv deps   │
               │ - runs isolated env    │
               │ - no pyproject edits   │
               │                        │
               │ This is the case either│
               │ with uv run script.py  │
               │ or ./script.py         │
               │ Add deps permanently:  │
               │ uv add --script        │
               │   script.py pkg1 pkg2  │
               └────────────────────────┘

```

Notes:

* `uv add pkg` → installs into .venv + updates pyproject.toml + uv.lock.
* `--with` deps are ephemeral overlays, not persistent installs.
* Use `--no-project` to force ignoring the project env entirely. Useless to use it while running via a shebang(inside of the project) because it is using isolated env by default.
* The reason for this behavior of `--with` in a project is to allow testing of scripts using different versions of the same dependencies(say `uv run --with httpx==0.26.0 script.py`,`uv run --with httpx==0.25.0 script.py`, etc.)

## Uv pip

### 1. **Environment selection rules for `uv pip install`**

When you run `uv pip install`, uv applies this priority to determine where to install:

1. **Activated virtual environment** (`VIRTUAL_ENV`)
2. **Activated Conda environment** (`CONDA_PREFIX`)
3. **`.venv` in the current directory or nearest parent**
   ([Astral Docs][1])

This means you can control where dependencies go—into your project's or another venv—by manipulating activation.

### 2. **`uv add` ignores activation**

Unlike `uv pip install`, the `uv add` command (and similar project-scoped commands like `uv sync`) **does not respect the currently activated virtual environment**. Instead, `uv add` will always work with the project's local `.venv`, creating it if necessary—even if you have another venv active.

* If you're inside a project directory and you run `uv add ruff`, it will always install into `.venv` in that directory.
* If `.venv` doesn’t exist yet, it creates one.
* This happens regardless of any active `VIRTUAL_ENV` from elsewhere.
  ([GitHub][2])

[1]: https://docs.astral.sh/uv/pip/environments/?utm_source=chatgpt.com "Using Python environments - uv - Astral Docs"
[2]: https://github.com/astral-sh/uv/issues/6612?utm_source=chatgpt.com "`uv add`/`uv sync`/... do not respect the active virtualenv, ..."


## Uv lock

### Q/A uv lock

**Q:**When I run uv sync I don't use a `pyproject.toml` but a lock file? Or am I wrong?

**A:** You use **both**—they play different roles during `uv sync`.

* **`pyproject.toml` (required):** declares what your project *wants* (deps, groups, Python constraint, extras, etc.). `uv sync` always reads this.
* **`uv.lock` (optional but recommended):** if present, `uv sync` will **install exactly what’s pinned** in the lockfile (no re-resolve). If it’s **absent**, `uv sync` will resolve versions from the rules in `pyproject.toml` and then **create**/update `uv.lock`.

Think of it like this:

1. First time (no lockfile yet)

```bash
uv sync
```

* Reads `pyproject.toml`
* Resolves versions
* Writes `uv.lock`
* Installs packages

2. Subsequent times (lockfile present)

```bash
uv sync
```

* Reads `pyproject.toml` to understand the project + groups
* Uses **`uv.lock`** to install the exact pinned versions (deterministic, no re-resolve)

3. When you *want* newer versions (within the ranges in `pyproject.toml`)

```bash
uv lock --upgrade
uv sync
```

* `uv lock --upgrade` re-resolves and updates `uv.lock`
* `uv sync` installs those new pinned versions

So `uv sync` prefers the lockfile for the exact versions, but it still needs `pyproject.toml` for the project definition and dependency groups. If no lockfile exists, `uv sync` creates it from the `pyproject.toml`.

**Q:**Why `uv.lock` matters vs. just `pyproject.toml`
**A:**

* **`pyproject.toml`** defines what your project *wants* — e.g. “mlflow >=2.9,<3”.
* **`uv.lock`** records what you *actually got* — the exact versions of every dependency (including transitives) plus their hashes.

Without a lockfile, installs can drift over time or differ across machines (newer sub-dependencies, OS-specific resolution). With a lockfile, `uv sync` always reproduces the same environment everywhere, ensuring determinism and security.

**Best practice:** Commit both `pyproject.toml` and `uv.lock` — the former expresses intent, the latter guarantees reproducibility.

### Quick cheatsheet(uv lock)

* Reproduce exactly (CI/teammates): `uv sync`
* Upgrade within your version ranges: `uv lock --upgrade` (then commit the new `uv.lock`)
* Skip dev deps: `uv sync --no-dev`
* Don’t prune extras during migration: `uv sync --inexact`

# Q/A general

Does `uv venv` or `uv sync` create a venv if one doesn't exist in the folder where `pyproject.toml` exists by default?
:   Yes

Looks like if sources, `uv python find` will use that one.
