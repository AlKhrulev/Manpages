set shell := ["zsh", "-uc"]
alias p := preview
alias b := build

setup section:
    mkdir -p "rendered_pages/man{{section}}" 2> /dev/null

# convert section: (setup section)
convert section:
    parallel \
    "pandoc --standalone --to man {} -o rendered_pages/man{{section}}/{/.}" \
    ::: markdown/*.md

build section: (setup section) (convert section)
    [ "$(ls -l markdown/ | wc -l)" -eq "$(ls -l rendered_pages/man{{section}} | wc -l)" ]

# build & preview a single man page
preview name:
    man <(pandoc --standalone --to man markdown/{{name}}.1.md)

compress section:
    parallel 'gzip' ::: rendered_pages/man{{section}}/*

uncompress section:
    parallel 'uncompress' ::: rendered_pages/man{{section}}/*

clean:
    rm -vR rendered_pages/*