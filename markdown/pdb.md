% pdb(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2026-11-25

# NAME

pdb - Python's interactive debugger

# SYNOPSIS

```sh
python3 -m pdb [-c command] ... script.py [args ...]
```

# DESCRIPTION

Run a script under pdb, or insert `breakpoint()` in Python code to enter the debugger at that point. At the `(Pdb)` prompt, use debugger commands or evaluate Python expressions.

# COMMON COMMANDS

| Command | Action |
|---|---|
| `l` / `ll` | List nearby source / current function or frame. |
| `n` | Next line; step over calls. |
| `s` | Step into a call. |
| `c` | Continue until a breakpoint or program exit. |
| `r` | Continue until the current function returns. |
| `b` | List breakpoints. |
| `b [file:]line` | Set a breakpoint; optionally append `, condition`. |
| `tbreak [file:]line` | Set a one-shot breakpoint. |
| `cl number` | Clear a breakpoint; `disable` / `enable number` toggle it. |
| `w` | Show the stack. |
| `u` / `d` | Move up / down the stack. |
| `p expression` / `pp expression` | Print / pretty-print an expression. |
| `!statement` | Execute a Python statement explicitly. |
| `interact` | Start an interactive Python interpreter in the current frame; exit it with `exit()` or Ctrl-D to return to pdb. |
| `a` | Show arguments of the current function. |
| `h [command]` | Show help. |
| `q` | Quit the debugger. |

# USAGE

```sh
python3 -m pdb main.py arg1
```

Execution initially stops before the first line. For example:

```text
(Pdb) n
(Pdb) p some_variable
(Pdb) c
```

Alternatively, put `breakpoint()` in your code and run `python3 main.py` normally. For post-mortem debugging after an exception in a Python REPL:

```python
import pdb
pdb.pm()
```

# BREAKPOINTS ACROSS FILES

Suppose `main.py` imports `a.py`. From the project directory, set breakpoints before continuing, including in a file not yet imported:

```sh
python3 -m pdb -c 'b main.py:10' -c 'b a.py:15' -c continue main.py
```

Or set them at the `(Pdb)` prompt after starting `python3 -m pdb main.py`:

```text
(Pdb) b main.py:10
(Pdb) b a.py:15
(Pdb) b a.py:20, x > 3
(Pdb) b
(Pdb) c
```

The `.py` suffix may be omitted: `b main:10` and `b main.py:10` both work. Use executable line numbers; pdb searches for files on `sys.path`. If a file cannot be found, provide its path explicitly. A breakpoint only stops execution if that line is reached; its condition is evaluated in that frame.
