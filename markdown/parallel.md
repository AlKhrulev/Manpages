% Parallel(ak) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2025-03-04

# GNU Parallel — concise cheatsheet

## Mental model
- `parallel [opts] COMMAND ::: item1 item2 ...`
- `{}` = current input item  
- `{#}` = job slot number (1..N)  
- `{= perl =}` = inline transform (advanced)

## Linking

| Option     | Source Type  | Combination Mode  | Length mismatch behavior |
| ---------- | ------------ | ----------------- | ------------------------ |
| `:::`      | command line | Cartesian product | Generates Cartesian prod |
| `:::+`     | command line | zip with previous | Stops at shortest list   |
| `::::`     | file input   | Cartesian product | Stops at shortest file   |
| `::::+`    | file input   | zip with previous | Stops at shortest file   |
| `--link`   | any          | zip all inputs    | Stops at shortest source |
| `--xapply` | any          | zip all inputs    | Stops at shortest source |

### Wrapping behaviour

```bash
parallel echo ::: A B C :::+ 1 2
# echo A 1
# echo B 2
```
Note that C is ignored as the max length is 2

```bash
# note that cartesian mode is different
parallel echo ::: A B C ::: 1 2
# generates A 1, A 2, B 1, B 2, C 1, C 2
```

## Inputs (command line)

### Simple list
```bash
parallel echo {} ::: a b c
````

### Numbers / sequences

```bash
parallel echo {} ::: {1..10}
parallel echo {} ::: $(seq 1 10)
```

### From `xargs`-style pipelines

```bash
printf "%s\n" a b c | parallel echo {}
```

### Read NUL-delimited (safe for weird filenames)

```bash
find . -type f -print0 | parallel -0 echo {}
```

---

## Inputs (files)

### One item per line from file

```bash
parallel echo {} :::: items.txt
```

### Multiple input files (concatenate streams)

```bash
parallel echo {} :::: a.txt b.txt
```

### CSV / TSV as input

```bash
# CSV: split on comma
parallel --colsep ',' 'echo "A={1} B={2}"' :::: data.csv

# TSV: split on tab
parallel --colsep '\t' 'echo "A={1} B={2}"' :::: data.tsv
```

---

## Passing multiple arguments

### “Zipped” arguments (pairwise)

```bash
parallel 'echo user={1} host={2}' ::: alice bob ::: host1 host2
# -> (alice,host1) (bob,host2)
```

### Cartesian product (all combinations)

```bash
parallel --xapply 'echo {1} {2}' ::: a b ::: 1 2     # zipped
parallel         'echo {1} {2}' ::: a b ::: 1 2     # product
```

### Positional args from a single line (space-separated)

```bash
# lines like: "src dst"
parallel 'cp {1} {2}' :::: pairs.txt
```

### Multiple columns with custom separator

```bash
# lines like: "src|dst|mode"
parallel --colsep '\|' 'install -m {3} {1} {2}' :::: triples.txt
```

### Read two files in lockstep (zipped)

```bash
parallel --xapply 'echo {1} {2}' :::: users.txt :::: hosts.txt
```

---

## Common placeholders & file convenience

### Filename parts (works best when input is a path)

```bash
parallel 'echo full={} base={/} dir={//} noext={.} ext={..}' ::: /tmp/a.tar.gz
# {}    = /tmp/a.tar.gz
# {/}   = a.tar.gz
# {//}  = /tmp
# {.}   = /tmp/a.tar
# {..}  = gz
```

### Strip extension / rename output

```bash
parallel 'ffmpeg -i {} {.}.mp3' ::: *.wav
```

### Add a prefix/suffix

```bash
parallel 'echo "in:{} out:out_{}"' ::: a b
```

### Job index and total-ish info

```bash
parallel 'echo job={#} item={}' ::: a b c
```

---

## Quoting & commands that contain quotes

### Rule of thumb

* Put the *whole* command in **single quotes** for Parallel.
* Use **double quotes** inside when needed.
* If you need a literal single quote inside single quotes: close/open and escape: `'\''`

### Example: command needs double quotes inside (easy)

```bash
parallel 'printf "name=%s\n" "{}"' ::: "Alice Bob" "Carol"
```

### Example: embed a JSON string (quotes inside quotes)

```bash
parallel 'curl -s -X POST -H "Content-Type: application/json" \
  -d "{\"user\":\"{}\",\"role\":\"dev\"}" https://example/api' ::: alice bob
```

### Example: literal single quote inside the executed command

```bash
parallel 'echo '\''O'\''Reilly'\'' : {}' ::: book1 book2
```

### If quoting gets ugly: use `bash -c` with a positional parameter

```bash
parallel bash -c 'echo "item=$1"; echo "He said: \"hi\""' _ {} ::: a b
```

---

## Execution control (most used)

### Jobs / load

```bash
parallel -j4 COMMAND ::: ...
parallel -j0 COMMAND ::: ...        # as many as possible
parallel --load 80% COMMAND ::: ... # throttle by system load
```

### Keep output readable

```bash
parallel --lb COMMAND ::: ...       # line-buffered
parallel -k COMMAND ::: ...         # keep input order
```

### Dry run / preview

```bash
parallel --dry-run COMMAND ::: ...
parallel --verbose  COMMAND ::: ...
```

### Halt on failures

```bash
parallel --halt soon,fail=1 COMMAND ::: ...
```

### Progress

```bash
parallel --progress COMMAND ::: ...
parallel --eta      COMMAND ::: ...
```

---

## Classic recipes

### Run a command per file

```bash
parallel gzip {} ::: *.log
```

### Find + act (safe)

```bash
find . -name '*.jpg' -print0 | parallel -0 'convert {} -resize 50% {.}_small.jpg'
```

### Parallel SSH (pair host + command)

```bash
parallel --xapply 'ssh {1} {2}' ::: host1 host2 ::: 'uptime' 'df -h'
```

### Use replacement strings with braces

```bash
parallel 'mkdir -p {//}/out; cp {} {//}/out/{/}' ::: **/*.txt
```
