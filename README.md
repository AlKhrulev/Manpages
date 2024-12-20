# Manpages

A repo containing custom Markdown files that can be converted into man pages. I am including only options that are useful to me, so this is in no way a try to rewrite default man pages.

## Dependencies

Generally, all you need is some `.md` to `man` conversion tool. For my own convenience, I've chosen a set of programs I've worked with before but feel free to choose any other alternative.

For ex, you can use `make` instead of `just` or even use no build system at all. In that case, you will have to rewrite building commands manually(say, [this line](./justfile#L22) `parallel pandoc --standalone --to man {} -o rendered_pages/man{{section}}/{/.}.{{section}}` will become `parallel pandoc --standalone --to man {} -o rendered_pages/man${SECTION}/{/.}.${SECTION}`, where `SECTION` is a shell variable and so on.)

Nevertheless, here is my setup:

1. [just](https://github.com/casey/just) for running commands
2. [gnu parallel](https://www.gnu.org/software/parallel/) for efficiently converting many man pages simultaneously
3. [pandoc](https://pandoc.org/) to convert `.md` files in [markdown](./markdown/) folder into rendered man pages in `rendered_pages` folder

## Usage

Provided all of your dependencies are installed, simply run `just b` or `just build` to build all man pages and then add the 2 printed statements into your `~/.bashrc` or `~.zshrc` file.
In my case, I added:

```{bash}
# dynamically adds folder with compiled pages into MANPATH
export MANPATH="$(manpath):${HOME}/Downloads/Manpages/rendered_pages"
# makes both old and new sections available for discovery
export MANSECT=1:n:l:8:3:0:2:3posix:3pm:3perl:3am:5:4:9:6:7:ak
```

## Known Caveats

1. `MANSECT` might be incorrectly defined for non-Linux systems, so you might have to tweak it on [this line](./justfile#L3)
2. Both section name and man pages extension *must be identical*(ex. for the section `"test"`, the folder name must be `mantest` and man pages must end with `.test`) to be recognized correctly (for `docker`, it would then be `man test docker`)

## TODO

- [] Verify OSX support(the config file location might be different, so current `grep` approach might not work)
- [] Create a `Makefile` to reduce the number of dependencies