% hunspell(1) | General Commands Manual
% Alexander Khrulev (AlKhrulev [at] GitHub)
% 2026-08-27

## Check a file interactively

```bash
hunspell file.txt
```

Run without a file (or read from stdin) to type words and sentences interactively — each line is checked as you enter it, with the same commands as below. This is the same REPL mode either way:

Hunspell steps through every misspelled word and prints suggestions:

```
& recieve 6 0: receive, relief, ...

?
```

Type a number to pick a suggestion. Other commands:

| Command | Meaning |
|---|---|
| `N` (number) | replace with suggestion N |
| `R` then text | replace with custom text |
| `A` | accept word for this session |
| `I` | insert word as typed into personal dict |
| `U` | insert lowercase form into personal dict |
| `S` | stem / analyze the word |
| `?` | help |
| `q` / Ctrl-D | quit |

## List misspelled words: `-l`

```bash
echo "recieve teh wrods" | hunspell -l
recieve
teh
wrods
```

Prints only the misspelled words, one per line, then exits. Useful with `sort`:

```bash
hunspell -l README.md | sort -u
```

## Scriptable mode: `-a`

Like `-l`, but each answer is prefixed (`*` correct, `&` misspelled with suggestions) so a script or editor plugin can parse it. Not meant for interactive use — for that, just run `hunspell` with no flags.

## Dictionaries

By default hunspell uses the system dictionary (here: `en_CA`). To pick another one:

```bash
hunspell -d en_GB -l README.md
```

List what is installed:

```bash
hunspell -D </dev/null
```

Words added with `I` are saved to `~/.hunspell_<lang>` and used on later runs.

## Markup files

Pass `-H` for HTML or `-n` for man pages so tags are not counted as words:

```bash
hunspell -l -H page.html
hunspell -l -n page.1
```
