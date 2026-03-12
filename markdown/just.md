# `just` Command Runner — Practical Cheat Sheet

## 1. Variables

### Define variables

```make
project := "acme"
bin := "./bin"
git_sha := `git rev-parse --short HEAD`
````

### Use variables

```make
build:
  @echo "project={{project}} sha={{git_sha}}"
  @mkdir -p {{bin}}
```

### Override at runtime

```bash
just build project=beta bin=dist
```

---

## 2. Recipe Parameters (Arguments)

### Required argument

```make
say name:
  @echo "hello {{name}}"
```

```bash
just say Ada
```

### Optional arguments (defaults)

```make
greet name="world" punct="!":
  @echo "hello {{name}}{{punct}}"
```

```bash
just greet
just greet Ada
just greet Ada punct="!!!"
```

### Variadic arguments

One or more:

```make
backup +FILES:
  scp {{FILES}} me@server:
```

Zero or more:

```make
commit MESSAGE *FLAGS:
  git commit {{FLAGS}} -m "{{MESSAGE}}"
```

```bash
just backup a.txt b.txt
just commit "wip"
just commit "wip" --no-verify -s
```

---

## 3. Expressions & Dynamic Defaults

### Conditional expression

```make
who := if env_var("CI") == "" { "local" } else { "ci" }

show:
  @echo "{{who}}"
```

### Default from shell

```make
# shell() captures stdout of a shell and trims newline
author name=(shell("git config user.name")):
  @echo "author={{name}}"
```

```bash
just author
just author "Override Name"
```

---

## 4. Dependencies

### Simple dependency

```make
fmt:
  ruff format .

check: fmt
  ruff check .
```

```bash
just check
```

### Dependency with argument passing

```make
build target:
  @echo "Building {{target}}"

push target: (build target)
  @echo "Pushing {{target}}"
```

```bash
just push api
```

### Multiple dependencies

```make
ci target: fmt (build target) (test target)

test target:
  @echo "Testing {{target}}"
```

---

## 5. Groups (for `just --list` organization)

```make
[group: 'dev']
run:
  npm run dev

[group: 'dev']
test:
  npm test

[group: 'release']
publish:
  npm publish
```

```bash
just --groups
just --list
```

---

## 6. Configuring the Shell

### Set shell for linewise recipes

```make
set shell := ["bash", "-uc"]
```

---

## 7. Shebang Recipes (Run as Script Instead of Linewise)

Use when you need multiline shell logic:

```make
scripted:
  #!/usr/bin/env bash
  set -euo pipefail
  if true; then
    echo "works"
  fi
```

---

## 8. Common Caveats

### Each line runs separately (linewise mode)

This does NOT work:

```make
broken:
  cd subdir
  pwd
```

Fix:

```make
fixed:
  cd subdir && pwd
```

---

### Multiline shell constructs break in linewise mode

This fails:

```make
broken:
  if true; then
    echo hi
  fi
```

Fix (single line):

```make
ok:
  if true; then echo hi; fi
```

Or use shebang recipe.

---

### Quote interpolations if spaces are possible

```make
catfile path:
  cat "{{path}}"
```

---

## 9. Useful Patterns

### Default recipe

```make
default:
  @just --list
```

### Help recipe

```make
help:
  @echo "Examples:"
  @echo "  just greet Ada punct='!!'"
  @echo "  just ci api"
```

---

## 10. Invocation Patterns

Override variables:

```bash
just build target=api
```

Pass arguments:

```bash
just push api
```

Mix both:

```bash
just push api env=prod
```

---

# Mental Model

* `:=` defines variables.
* `{{var}}` interpolates values.
* `name arg1 arg2:` defines a recipe.
* `arg="default"` makes args optional.
* `+ARG` = one or more.
* `*ARG` = zero or more.
* `recipe: dep1 (dep2 arg)` defines dependencies.
* Linewise by default; use `&&` or a shebang for real scripts.

