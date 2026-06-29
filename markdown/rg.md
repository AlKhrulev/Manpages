# RIPGREP REGEX TL;DR

## Engine

Default:

```sh
rg PATTERN
```

- Fast Rust regex engine
- No backreferences or lookaround

PCRE2:

```sh
rg -P PATTERN
```

Enables backreferences, lookahead/lookbehind, lazy quantifiers, etc.

---

## Regex Grammar

### Atoms (things that match)

| Atom | Meaning |
|------|---------|
| `a` | literal character |
| `.` | any character except newline |
| `\d` | digit |
| `\w` | word character (`[A-Za-z0-9_]`) |
| `\s` | whitespace |
| `[abc]` | one of `a`, `b`, `c` |
| `[^abc]` | anything except `a`, `b`, `c` |
| `( ... )` | group |
| `^` | start of line |
| `$` | end of line |
| `\b` | word boundary |

---

### Quantifiers (apply to the PREVIOUS atom)

| Quantifier | Meaning |
|------------|---------|
| `*` | zero or more |
| `+` | one or more |
| `?` | zero or one |
| `{n}` | exactly `n` |
| `{m,n}` | between `m` and `n` |

Examples:

| Pattern | Meaning |
|---------|---------|
| `ab*` | `a` followed by zero or more `b`s |
| `\d+` | one or more digits |
| `[A-Z]?` | optional capital letter |
| `(abc)+` | repeat `"abc"` |

---

### Concatenation

Patterns written next to each other are matched in sequence.

`abc`

means

- `a`
- then `b`
- then `c`

---

### Alternation (`|`)

`|` has the **lowest precedence**.

```
foo|bar
```

means

```
(foo) OR (bar)
```

NOT

```
fo(o|b)ar
```

To limit the scope of `|`, use parentheses.

Example:

| Pattern | Matches |
|---------|----------|
| `fo(o|b)ar` | `fooar`, `fobar` |
| `cat|dog` | `cat` or `dog` |

---

## Operator Precedence

Highest → Lowest

1. Atoms

   ```
   a
   .
   \d
   [a-z]
   (...)
   ```

2. Quantifiers

   ```
   *
   +
   ?
   {m,n}
   ```

3. Concatenation

   ```
   abc
   ```

4. Alternation

   ```
   |
   ```

Examples:

| Pattern | Equivalent |
|---------|------------|
| `abc+` | `ab(c+)` |
| `(abc)+` | repeat `"abc"` |
| `foo|bar` | `(foo) OR (bar)` |
| `ab+c|de` | `(ab+c) OR (de)` |

---

## Character Classes

| Pattern | Meaning |
|---------|---------|
| `[abc]` | one of |
| `[^abc]` | not one of |
| `[a-z]` | range |
| `\d` | digit |
| `\D` | non-digit |
| `\w` | word |
| `\W` | non-word |
| `\s` | whitespace |
| `\S` | non-whitespace |

---

## Anchors

| Pattern | Meaning |
|---------|---------|
| `^` | start of line |
| `$` | end of line |
| `\b` | word boundary |
| `\B` | not a word boundary |

---

## Common Patterns

| Pattern | Meaning |
|---------|---------|
| `^foo` | starts with `foo` |
| `bar$` | ends with `bar` |
| `^$` | empty line |
| `^\s*$` | blank line |
| `foo.*bar` | `foo` before `bar` |
| `\bTODO\b` | whole word `TODO` |
| `[0-9]{4}` | four digits |
| `colou?r` | `color` or `colour` |

---

## Useful `rg` Flags

| Flag | Meaning |
|------|---------|
| `-i` | ignore case |
| `-S` | smart case |
| `-w` | whole words |
| `-x` | whole line |
| `-v` | invert match |
| `-n` | line numbers |
| `-c` | count matches |
| `-l` | filenames only |
| `-L` | files without matches |
| `-o` | only matching text |
| `-A N` | `N` lines after |
| `-B N` | `N` lines before |
| `-C N` | context |
| `-g GLOB` | include/exclude paths |
| `-t TYPE` | file type |
| `-T TYPE` | exclude file type |
| `-F` | fixed string (no regex) |
| `-P` | PCRE2 |
| `-e PATTERN` | additional pattern |
| `-u` | include hidden files |
| `-uu` | include ignored files |
| `-uuu` | include binary files |

---

## PCRE2-only (`-P`)

| Pattern | Meaning |
|---------|---------|
| `.*?` | lazy match |
| `(?:...)` | non-capturing group |
| `(?=...)` | lookahead |
| `(?!...)` | negative lookahead |
| `(?<=...)` | lookbehind |
| `(?<!...)` | negative lookbehind |
| `\1` | backreference |

---

## Escaping

Literal regex metacharacters:

```
\.  \*  \+  \?  \(  \)  \[  \]  \{  \}  \|  \\
```

---

## Tip

Searching literal text?

```sh
rg -F 'a+b*c'
```

instead of escaping regex metacharacters.

---

## Mental Model

Regex parses like this:

```
Atoms
  ↓
Quantifiers
  ↓
Concatenation
  ↓
Alternation
```

Remember:

- Quantifiers (`*`, `+`, `?`, `{}`) apply to the **previous atom**.
- Concatenation binds tighter than `|`.
- `|` separates complete expressions unless parentheses say otherwise.