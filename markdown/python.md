% Python(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-06

# NAME

Python - General programming language

# SYNOPSIS

```{bash}
python [-m MODULENAME] FILENAME
python -m Pdb -c c FILENAME
```

# DESCRIPTION

Test new

# Options
`-m MODULENAME`
:   Run a specific module


## Debugger

### Breakpoint location

If line has code on it, breakpoint will be inserted *before the code on that line*

```{bash}
python3 -m pdb -c 'b 1' remove_me.py
Breakpoint 1 at .../remove_me.py:1
(Pdb) l
  1 B->	a=5
  2  	print(a)
[EOF]
(Pdb) p a
*** NameError: name 'a' is not defined
(Pdb) n
> .../remove_me.py(2)<module>()
-> print(a)
(Pdb) p a
5
```

## References

https://eddieantonio.ca/blog/2015/12/18/authoring-manpages-in-markdown-with-pandoc/

https://gabmus.org/posts/man_pages_with_markdown_and_pandoc/
