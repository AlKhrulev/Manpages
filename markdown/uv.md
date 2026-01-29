% uv(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2025-08-15

# NAME

A custom man page for **uv**

# SYNOPSIS

# DESCRIPTION

A collection of useful uv commands

# uv interpreter/env selection (flow)

## TLDR for interpreter/venv selection

### Selection For `uv run script.py` or `uv run --script SomeFile`(script mode)

1. Inline deps defined=>create isolated venv with those, use it, terminate
2. Otherwise, is `--python` passed? It so, use that python, terminate; continue otherwise
3. Are we in a project? If so, use the project venv, terminate; continue otherwise or if `--no-project`, `--active` are passed
4. Do we have an active venv(`$VIRTUAL_ENV`) or did we pass `--no-project,--active`? If so, use it and terminate. Otherwise, skip to next step.
5. Recursively(going up to system root) find the closest `.venv` folder and use it(if exists), terminate . Continue otherwise. Note that this `.venv` folder might be in `$PWD` or above as well.
6. Use the `PATH` to find system python interpreter and use it, terminate.

### Selection For `uv run command`(command mode)

Same as above but if we at any point we hit an existing case and can't find a necessary dependency, instead of terminating will go to point #6 as well. Probably this is done to allow global command discovery when they were installed via `uv tool install`, etc.

### Adding extra deps to the discovered environment

If you hit some case, you might exit with an error if the existing env doesn't have dependencies to run your code. When you pass the flags `--with requirement`/`--with-requirements requirements.txt` these will be layered on top of existing dependencies defined in the found environment.

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

`uv init --bare`
: only create `pyproject.toml`

uv init --script *ScriptName*:
: Initializes inline metadata`///script, requires-python, dependencies=[]` for *ScriptName*

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

`uv add --script script.py mlflow==2.0.0 ...`
:   Update script.py, inserting a TOML-style metadata block at the top that declares the dependency. `uv run script.py` will automatically use it

`uv cache prune`
:   prune unreachable packages

`uv pip compile pyproject.toml -o requirements.txt`
:   produce `requirements.txt` for export based on `pyproject.toml`. Because of `pip-compile` nature, the file includes not just the direct dependencies that your code imports directly, but also versions for all of the transitive dependencies as well, that is, the versions of modules that your directly dependent modules themselves depend on. Essentially, this is a version of lock file that uses `pip-compile`

`uv pip install [--strict] ...`
:   Validate the Python environment after completing the installation, to detect packages with missing dependencies or other issues

`uv pip install [--dry-run] [--offline]...`
:   Self-explanatory

`uv pip list`
:   List all packages installed in the current venv

`uv tree`
:   View a dependency graph

`uv python find`
:   Determine which executable will be used

uv run \[*UvArgs*...] *Filename*.py \[*FileArgs*...]
:   Analogous to uv run python *Filename*.py(i.e. **"script mode"**) but **uv inspects the script** for PEP 723 inline dependency metadata. The .py exception is mandatory for uv to recognize that the argument is actually a python script that has to be run. The usual resolution order for selecting python interpreter for `uv run` is applied(i.e. project->active venv->.venv folder in current or parent folders->check `PATH`).

`uv run ./someFile`
:   This **will not work** as uv will be looking for a command ./someFile using the command mode! See below for the correct versionß

`uv run python someFile`
:   This will work as we explicitly use the correct command. However, this looks to be ignoring PEP 723 Inline script metadata(i.e. no automatic empheral env. set up for you )

uv run \[*UvArgs*...] *Command* \[*CommandArgs*...]
:   Use the **command mode**(automatically if no .py exception is discovered). Will run the *Command* using the normal resolution order(i.e. project->active venv->.venv folder in current or parent folders->check `PATH`). See below for examples.

`uv run which python`
:   Should determine which python is used via `run` subcommand

`uv run echo abc`
:   Even this works, where `echo` is `/bin/echo`. This will **force syncing and locking** for active project though!

`uv run --offline ...`
:   Use only local cache for package installation

`uv run python -c "import sys; print(sys.prefix)"`
:   Print path to currently used Python

`uv run --isolated [--with[--requirements]]...`
: makes a throwaway scratch environment (in a temp dir) environment populated only with what I specify(ignore active venv, .venv). Will still use project venv deps unless `--no-project` flag is passed.

`uv python pin 3.12`
:   Create a file `.python-version` so that uv would only use that version

`uv export -o pylock.toml`
:   Export lock file using a new standardized `pylock.toml` format

`uv tree --script path/to/your_script.py`
:   Output a hierarchical listing of all direct and transitive dependencies of the script. Uses PEP 723 inline metadata.

`uv lock --script your_script.py`
:   his creates a .lock file alongside the script (e.g., `your_script.py.lock`). Subsequent `uv tree --script` runs will respect and reflect the locked versions, same for `uv run`.

`uv run --locked script.py`
: fail if the lock would change or is missing

`uv run --frozen script.py`
: use the lockfile as-is; fail if missing; run without updating to possible comparable versions

## uv add

## Uv run Resolution Order

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

## `uv run package` resolution order

### Rules for `uv run package`

```shell
Start: uv run <cmd|script|package>
(Project detected)

 ├── Is --python <path|version> given?
 │     └─ Yes → Use that interpreter/env, then continue in that env. [stops here for interpreter choice]
 │     └─ No  → continue
 │
 ├── --no-project passed?
 │     └─ Yes → Switch to the *outside‑project* flow (the tree you already have:
 │               active venv > nearest .venv (single stop) > fallback interpreter). 
 │               (See previous diagram.)
 │     └─ No  → continue (project mode)
 │
 ├── Should the active venv be preferred? ( --active )
 │     └─ Yes → If a venv is currently active (VIRTUAL_ENV set), prefer it over the project venv.
 │     └─ No  → continue
 │
 ├── Ensure project environment
 │     └─ uv will (auto) lock + sync the project, then create/update the
 │        project virtual environment (usually at .venv).
 │
 ├── Choose environment to run in
 │     ├─ If --active AND an active venv exists → use the active venv.
 │     └─ Else → use the **project’s .venv**. (This is the default.)
 │
 ├── Execute command
 │     ├─ If you reference a *package/console script* that is NOT installed in that env,
 │     │   it won’t “search higher” or auto‑install unless you ask it to:
 │     │     • add it to the project + `uv sync`, or
 │     │     • run with **`--with <pkg>`** for an ephemeral add during the run.
 │     └─ If you run a **script** (`script.py`), it simply runs within the chosen env.
 │
 └── Done.

```

### Practical example for `uv run script.py`

```
~geotab/uv_test/second_dir $ cd third_dir

~geotab/uv_test/s/third_dir $ nv run_me_with_rich.py

~geotab/uv_test/s/third_dir $ deactivate

# making sure project venv doesn't have rich
~geotab/uv_test/second_dir/third_dir $ uv pip uninstall rich --python=$(realpath ~geotab)/uv_test/.venv/bin/python
Using Python 3.11.11 environment at: /Users/alexkhrulev/Documents/geotab/uv_test/.venv
Uninstalled 1 package in 14ms
 - rich==14.1.0

# installed rich first cause it is present in pyproject.toml for the project and we use a project mode
~geotab/uv_test/second_dir/third_dir $ uv run run_me_with_rich.py
Installed 1 package in 3ms
hello world!

~geotab/uv_test/second_dir/third_dir $ uv remove rich
Resolved 1 package in 7ms
Uninstalled 11 packages in 90ms
 - black==25.1.0
 - click==8.2.1
 - markdown-it-py==4.0.0
 - mdurl==0.1.2
 - mypy-extensions==1.1.0
 - packaging==25.0
 - pathspec==0.12.1
 - platformdirs==4.3.8
 - pygments==2.19.2
 - rich==14.1.0
 - ruff==0.12.10

# defaults to project venv that doesn't have rich and fails as we don't traverse further
~geotab/uv_test/second_dir/third_dir $ uv run run_me_with_rich.py
Traceback (most recent call last):
  File "/Users/alexkhrulev/Documents/geotab/uv_test/second_dir/third_dir/run_me_with_rich.py", line 1, in <module>
    import rich
ModuleNotFoundError: No module named 'rich'

# install rich into venv for current dir
~geotab/uv_test/s/third_dir $ uv pip install rich
Resolved 4 packages in 61ms
Installed 4 packages in 9ms
 + markdown-it-py==4.0.0
 + mdurl==0.1.2
 + pygments==2.19.2
 + rich==14.1.0

# same result as before, we use project with no rich=>fail
~geotab/uv_test/second_dir/third_dir $ uv run run_me_with_rich.py
Traceback (most recent call last):
  File "/Users/alexkhrulev/Documents/geotab/uv_test/second_dir/third_dir/run_me_with_rich.py", line 1, in <module>
    import rich
ModuleNotFoundError: No module named 'rich'

# no project=>go to active venv(none)=>look at nearest .venv(it in in $PWD)
# luckily it has rich=>execute the script there
~geotab/uv_test/s/third_dir $ uv run --no-project run_me_with_rich.py
hello world!

~geotab/uv_test/second_dir/third_dir $ cat run_me_with_rich.py
import rich

print('hello world!')

# no more rich in current folder's venv
~geotab/uv_test/second_dir/third_dir $ uv pip uninstall rich
Uninstalled 1 package in 14ms
 - rich==14.1.0

# now, the top folder's venv has rich
~geotab/uv_test/second_dir/third_dir $ uv pip install --python=../.venv/bin/python rich
Using Python 3.11.11 environment at: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv
Audited 1 package in 3ms

# source venv with rich
~geotab/uv_test/second_dir/third_dir $ source ../.venv/bin/activate

# no project=>go to active venv(it has rich)=> run there
~geotab/uv_test/s/third_dir $ uv run --no-project run_me_with_rich.py
hello world!

# for myself, uv pip prefers active venv first
~geotab/uv_test/s/third_dir $ uv pip install rich
Using Python 3.11.11 environment at: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv
Audited 1 package in 1ms

~geotab/uv_test/s/third_dir $ uv pip uninstall rich
Using Python 3.11.11 environment at: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv
Uninstalled 1 package in 13ms
 - rich==14.1.0

~geotab/uv_test/s/third_dir $ deactivate

# now we have rich in the closest .venv folder($PWD)
~geotab/uv_test/second_dir/third_dir $ uv pip install rich
Resolved 4 packages in 95ms
Installed 1 package in 3ms
 + rich==14.1.0

# active venv without rich
~geotab/uv_test/second_dir/third_dir $ source ../.venv/bin/activate

# no project=>active venv. It doesn't have rich => error out
~geotab/uv_test/s/third_dir $ uv run --no-project run_me_with_rich.py
Traceback (most recent call last):
  File "/Users/alexkhrulev/Documents/geotab/uv_test/second_dir/third_dir/run_me_with_rich.py", line 1, in <module>
    import rich
ModuleNotFoundError: No module named 'rich'

# current .venv has riff now
~geotab/uv_test/second_dir/third_dir $ uv pip install ruff
Resolved 1 package in 49ms
Installed 1 package in 5ms
 + ruff==0.12.10

# activate venv without ruff
~geotab/uv_test/second_dir/third_dir $ source ../.venv/bin/activate

# no project=>active venv, then we default to PATH because
# v intentionally ignores the project it just discovered and doesn’t “enter” the project environment. It will still pick a # Python interpreter (your venv’s Python in your logs), but it doesn’t prepend the venv’s bin/ to PATH. So when you ask uv # to run which ruff, the lookup happens on your normal PATH and you get the global /opt/homebrew/bin/ruff. 
~geotab/uv_test/s/third_dir $ uv run --no-project which ruff
/opt/homebrew/bin/ruff

~geotab/uv_test/s/third_dir $ uv run --no-project -vvv which ruff
DEBUG uv 0.8.13 (Homebrew 2025-08-21)
DEBUG Found project root: `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG No workspace root found, using project root
DEBUG Ignoring discovered project due to `--no-project`
DEBUG No project found; searching for Python interpreter
DEBUG Reading Python requests from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Searching for Python 3.11 in virtual environments, managed installations, or search path
TRACE Found cached interpreter info for Python 3.11.11, skipping query of: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv/bin/python3
DEBUG Found `cpython-3.11.11-macos-aarch64-none` at `/Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv/bin/python3` (active virtual environment)
DEBUG Using Python 3.11.11 interpreter at: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/.venv/bin/python3
DEBUG Running `which ruff`
DEBUG Spawned child 56971 in process group 56970
/opt/homebrew/bin/ruff
DEBUG Command exited with code: 0

~geotab/uv_test/s/third_dir $ deactivate

~geotab/uv_test/second_dir/third_dir $ uv pip list
Package         Version
--------------- -------
black           25.1.0
click           8.2.1
markdown-it-py  4.0.0
mdurl           0.1.2
mypy-extensions 1.1.0
packaging       25.0
pathspec        0.12.1
platformdirs    4.3.8
pygments        2.19.2
rich            14.1.0
ruff            0.12.10

# note here we are running a python MODULE => no need for ruff to be on path
# => we CORRECTLY find the right ruff from the closest .venv after failing
# to do so via project_venv(as skipped), ACTIVE_VENV(as no active)
~geotab/uv_test/second_dir/third_dir $ uv run --no-project -vvv ruff --version
DEBUG uv 0.8.13 (Homebrew 2025-08-21)
DEBUG Found project root: `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG No workspace root found, using project root
DEBUG Ignoring discovered project due to `--no-project`
DEBUG No project found; searching for Python interpreter
DEBUG Reading Python requests from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Searching for Python 3.11 in virtual environments, managed installations, or search path
TRACE Found cached interpreter info for Python 3.11.11, skipping query of: .venv/bin/python3
DEBUG Found `cpython-3.11.11-macos-aarch64-none` at `/Users/alexkhrulev/Documents/geotab/uv_test/second_dir/third_dir/.venv/bin/python3` (virtual environment)
DEBUG Using Python 3.11.11 interpreter at: /Users/alexkhrulev/Documents/geotab/uv_test/second_dir/third_dir/.venv/bin/python3
DEBUG Running `ruff --version`
DEBUG Spawned child 57944 in process group 57943
ruff 0.12.10
DEBUG Command exited with code: 0

# imho, the only reason why this is working is cause it defaults to global ruff
~geotab/uv_test/second_dir/third_dir $ uv run -vvv ruff --version
DEBUG uv 0.8.13 (Homebrew 2025-08-21)
DEBUG Found project root: `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG No workspace root found, using project root
DEBUG Discovered project `uv-test` at: /Users/alexkhrulev/Documents/geotab/uv_test
TRACE Checking lock for `/Users/alexkhrulev/Documents/geotab/uv_test` at `/var/folders/z4/t_1t94x551z74ngmbrvcqdjr0000gp/T/uv-4f9cc01ec27fa160.lock`
DEBUG Acquired lock for `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG Reading Python requests from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Using Python request `3.11` from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Checking for Python environment at: `/Users/alexkhrulev/Documents/geotab/uv_test/.venv`
TRACE Found cached interpreter info for Python 3.11.11, skipping query of: /Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/python3
DEBUG The project environment's Python version satisfies the request: `Python 3.11`
TRACE The project environment's Python version meets the Python requirement: `>=3.11`
TRACE The virtual environment's Python interpreter meets the Python preference: `prefer managed`
DEBUG Released lock at `/var/folders/z4/t_1t94x551z74ngmbrvcqdjr0000gp/T/uv-4f9cc01ec27fa160.lock`
TRACE Checking lock for `/Users/alexkhrulev/Documents/geotab/uv_test/.venv` at `/Users/alexkhrulev/Documents/geotab/uv_test/.venv/.lock`
DEBUG Acquired lock for `/Users/alexkhrulev/Documents/geotab/uv_test/.venv`
DEBUG Using request timeout of 30s
DEBUG Found static `pyproject.toml` for: uv-test @ file:///Users/alexkhrulev/Documents/geotab/uv_test
DEBUG No workspace root found, using project root
DEBUG Existing `uv.lock` satisfies workspace requirements
Resolved 1 package in 5ms
DEBUG Using request timeout of 30s
Audited in 0.01ms
DEBUG Released lock at `/Users/alexkhrulev/Documents/geotab/uv_test/.venv/.lock`
DEBUG Using Python 3.11.11 interpreter at: /Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/python3
DEBUG Running `ruff --version`
DEBUG Spawned child 58640 in process group 58639
ruff 0.12.10
DEBUG Command exited with code: 0

~geotab/uv_test/second_dir/third_dir $ uv remove ruff
error: The dependency `ruff` could not be found in `project.dependencies`

~geotab/uv_test/s/third_dir $ uv run -vvv which ruff
DEBUG uv 0.8.13 (Homebrew 2025-08-21)
DEBUG Found project root: `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG No workspace root found, using project root
DEBUG Discovered project `uv-test` at: /Users/alexkhrulev/Documents/geotab/uv_test
TRACE Checking lock for `/Users/alexkhrulev/Documents/geotab/uv_test` at `/var/folders/z4/t_1t94x551z74ngmbrvcqdjr0000gp/T/uv-4f9cc01ec27fa160.lock`
DEBUG Acquired lock for `/Users/alexkhrulev/Documents/geotab/uv_test`
DEBUG Reading Python requests from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Using Python request `3.11` from version file at `/Users/alexkhrulev/Documents/geotab/uv_test/.python-version`
DEBUG Checking for Python environment at: `/Users/alexkhrulev/Documents/geotab/uv_test/.venv`
TRACE Found cached interpreter info for Python 3.11.11, skipping query of: /Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/python3
DEBUG The project environment's Python version satisfies the request: `Python 3.11`
TRACE The project environment's Python version meets the Python requirement: `>=3.11`
TRACE The virtual environment's Python interpreter meets the Python preference: `prefer managed`
DEBUG Released lock at `/var/folders/z4/t_1t94x551z74ngmbrvcqdjr0000gp/T/uv-4f9cc01ec27fa160.lock`
TRACE Checking lock for `/Users/alexkhrulev/Documents/geotab/uv_test/.venv` at `/Users/alexkhrulev/Documents/geotab/uv_test/.venv/.lock`
DEBUG Acquired lock for `/Users/alexkhrulev/Documents/geotab/uv_test/.venv`
DEBUG Using request timeout of 30s
DEBUG Found static `pyproject.toml` for: uv-test @ file:///Users/alexkhrulev/Documents/geotab/uv_test
DEBUG No workspace root found, using project root
DEBUG Existing `uv.lock` satisfies workspace requirements
Resolved 1 package in 4ms
DEBUG Using request timeout of 30s
Audited in 0.01ms
DEBUG Released lock at `/Users/alexkhrulev/Documents/geotab/uv_test/.venv/.lock`
DEBUG Using Python 3.11.11 interpreter at: /Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/python3
DEBUG Running `which ruff`
DEBUG Spawned child 58818 in process group 58817
/opt/homebrew/bin/ruff
DEBUG Command exited with code: 0

```

### Practical Example for `uv run package`

```shell
~geotab/uv_test/s/third_dir/forth_dir $ uv run which ruff # global ruff as no ruff is installed anywhere
/opt/homebrew/bin/ruff

~geotab/uv_test/s/third_dir/forth_dir $ cd ~geotab/uv_test

~geotab/uv_test $ uv pip install ruff # install into project venv
Resolved 1 package in 140ms
Prepared 1 package in 592ms
Installed 1 package in 7ms
 + ruff==0.12.10

~geotab/uv_test $ uv run which ruff # using project venv, so now have ruff there
/Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/ruff

~geotab/uv_test $ cd second_dir

~geotab/uv_test/second_dir $ uv run which ruff # still project venv
/Users/alexkhrulev/Documents/geotab/uv_test/.venv/bin/ruff

# no project=>look at active venv(none)=>closest .venv(=~geotab/uv_test/second_dir/.venv) that doesn't have it
# => look at PATH, which has a global ruff
~geotab/uv_test/second_dir $ uv run --no-project which ruff
/opt/homebrew/bin/ruff

# activating .venv which doesn't have ruff anyway
~geotab/uv_test/second_dir $ source .venv/bin/activate

# skip project=>look at active venv(it doesn't have ruff)=>look at closest .venv(same as $VIRTUAL_ENV right now), it
# doesn't have ruff either=>default to PATH, which has ruff
~geotab/uv_test/second_dir $ uv run --no-project which ruff
/opt/homebrew/bin/ruff

```

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

**Q:**When I run `uv sync` I don't use a `pyproject.toml` but a lock file? Or am I wrong?

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

## Custom artifact registry

### Raw `pip` command for artifact registry

```shell
uv pip install --extra-index-url https://europe-python.pkg.dev/geotab-data-platform/pymaas/simple pymaas==1.4.1
```

### Modifying config permanently for custom registry support

Here is an example based on `geotab-genai` package:

pyproject.toml:

```toml
dependencies = [
    ...,
    "geotab-genai"
]

[tool.uv]
keyring-provider = "subprocess"

[tool.uv.sources]
geotab-genai = { index = "gar" }

[[tool.uv.index]]
name = "gar"
url = "https://europe-python.pkg.dev/geotab-data-platform-test/geotab-genai/simple"
authenticate = "always"
explicit = true
```

And run the following commands:

```bash
# all of the following has to be done only once, besides the authentication
uv tool install keyring --with keyrings.google-artifactregistry-auth
uv tool update-shell # only if uv warns you that you need to do that after prev. command
gcloud auth application-default login
```

### One-time `uv add` call to add registry

#### Adding

```shell
# for authorization if not installed as a tool
uv add keyrings.google-artifactregistry-auth

uv add PACKAGE-NAME \
--keyring-provider subprocess \ 
--index https://oauth2accesstoken@{REGION}-python.pkg.dev/{PROJECT}/{REPO-NAME}/simple/

# alternative way to avoid passing --keyring-provider every time
export UV_KEYRING_PROVIDER=subprocess
```

#### Publishing

```shell
uv build # create .whl, .tar

uv publish \
--keyring-provider subprocess \
--publish-url https://oauth2accesstoken@{REGION}-python.pkg.dev/{PROJECT}/{REPO-NAME}/
```

Or add the following to `pyproject.toml`:

```toml
[[tool.uv.index]]
name = "{PRIVATE-REPO}"
url = "https://{REGION}-python.pkg.dev/{PROJECT}/{REPO-NAME}/simple/"
publish-url = "https://oauth2accesstoken@{REGION}-python.pkg.dev/{PROJECT}/{REPO-NAME}/"
```

And publish via

```shell
uv publish \
--keyring-provider subprocess \
--index {PRIVATE-REPO}
```

## Uv sync

`uv sync --only-group <group>`
: Sync dependencies only from the specified group(s). Use for minimal installs targeting one extras group.

`uv sync --no-editable`
: Install local packages as standard builds, not editable. Helpful for mimicking production installs.

`uv sync --refresh`
: Ignore cache and re-resolve dependencies freshly.

`uv sync --upgrade`
: Sync while upgrading dependencies to latest allowed versions.

`uv sync --upgrade-package <pkg>`
: Upgrade only a specific package while syncing.

`uv sync [--extra <extraGroup>] [--group <group>]`
: Sync just the given extras AND groups (and defaults)

common selector patterns (apply to uv lock and/or uv sync)

* Main only: `--no-dev`
* Main + dev (default): (no flag) or `--dev`
* Include extras: `--with <extra>`
* Exclude extras: `--without <extra>`
* Strict to lock (no re-resolve). Use for reproducible builds: `sync --frozen`
* Upgrade within constraints: `--upgrade` / `--upgrade-package <pkg>`

# Q/A general

Does `uv venv` or `uv sync` create a venv if one doesn't exist in the folder where `pyproject.toml` exists by default?
:   Yes for `uv sync`, no for `uv venv`(doesn't respect the project, so does `uv venv .venv`)

`uv run script.py` vs `uv python run script.py`
:   Use `uv run script.py` if you want uv to handle inline dependencies. Use `uv run python …` if you want more raw control (like running Python without dependency parsing).

Say I have a installed a bunch of packages into my env without using `uv add` and I want to update the lock file to reflect those. Can I somehow do it directly without touching pyproject.toml or do I still have to manually add those new packages there first?(ex. via `uv add ...`)
: The lock file (uv.lock) is always derived from the declared dependencies in pyproject.toml.
That means if you’ve manually `pip` install’d or otherwise added packages into your venv outside of `uv add` or editing `pyproject.toml`, uv has no way of knowing those should be part of the lock — they won’t get written unless they’re declared(=>do `uv run`, then `uv sync` or `uv lock`)

Does the call uv `lock` will always look at my `pyproject.toml`?
: `uv lock` always computes the lock file (uv.lock) from what’s declared in your pyproject.toml (plus any dependency groups/extras you tell it to include with flags). pyproject.toml is the source of truth, uv.lock is the resolved plan, and uv sync makes your environment match that plan.

`uv run --active` vs `--no-project`
: The former syncs and locks the project with active venv, the latter skips those steps

## Script mode vs command mode

When you type:

```bash
uv run something ...
```

`uv` has two major modes of operation:

1. **Script mode**
   If the first argument looks like a **Python script file** (ends in `.py` or is an executable file with a shebang), `uv` assumes you want to run *that script*.

   * It will parse the script for [PEP 723 inline dependencies](https://peps.python.org/pep-0723/).
   * If present, it resolves them into an ephemeral environment.
   * Then it runs the script in that environment.
   * `uv` checks `script.py` for `# /// script` metadata and installs deps automatically.

---

1. **Command mode**
   If the first argument is **not a `.py` file**, `uv` assumes it’s an executable or module name you want to run *inside a Python environment*.

   * In this case, `uv` doesn’t look at inline metadata from later arguments — it just runs the command.
   * If the command is `python`, it just launches Python, without peeking into your script.

---

* `uv run script.py` → script mode → inline deps are detected.
* `uv run python script.py` → command mode → inline deps are not detected.
* General rule: first arg = .py file → script mode, otherwise → command mode.

## `--extra` vs `--group` dependencies

### TLDR for `--extra` vs `--group`

* Want users to be able to opt into a feature after pip install yourlib? → Extras.
* Want developers/CI to install tool stacks or app contexts? → Dependency groups.

### Detailed breakthrough for `--extra` vs `--group`

* **Extras (`[project.optional-dependencies]`)**
  For **optional features your users can enable**.They’re published to PyPI, so downstream users can do:

  ```bash
  pip install package[google]
  uv run [--extra google]...
  uv sync [--extra google]...
  uv add "matplotlib[qt]"   # Add matplotlib with its optional Qt backend
  uv add --extra google google-genai
  ```

  In config, it will look like

  ```toml
  # PEP 621 standard for optional features of the package itself
  [project.optional-dependencies]
  google = ["google-genai"]
  openai = ["openai"]
  ```

  For ex. imagine you are working on a RAG application and allow users to optionally add support for google, openai,etc. models. This will require they to fetch extra files.

* **Dependency groups (`[dependency-groups]`)**
  For **local/dev workflows** (tests, docs, CI). They’re **not published**, so only you/your team can install them with tools that support groups, e.g.:

  ```bash
  pip install --group dev
  uv sync [--group docs]...
  uv add --group serving rich
  uv run --group docs sphinx-build docs/ build/ #Include dependencies from docs
  ```

  In config, it will look like

  ```toml
  # PEP 735 draft (Dependency Groups for Python Packaging) which uv already supports
  [dependency-groups]
  test = ["pytest", "coverage"]
  docs = ["sphinx"]
  ```

  You might also see something like this:

  ```toml
  # uv-specific (inspired by Poetry groups). Designed for workflow/environment separation.
  [tool.uv.dependencies]
  dev = ["pytest", "mypy"]
  docs = ["sphinx"]
  ```
