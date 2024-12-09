set shell := ["zsh", "-uc"]
all_sections := `grep '^SECTION' /etc/manpath.config | tr -s ' \t' ':' | cut -d ":" -f2-`
alias p := preview
alias b := build
# use @ to suppress verbose printing

verify_dependencies:
    @command -v parallel > /dev/null
    @command -v pandoc > /dev/null

setup section="ak":
    mkdir -p "rendered_pages/man{{section}}" 2> /dev/null

# convert section: (setup section)
convert section="ak": verify_dependencies
    parallel \
    "pandoc --standalone --to man {} -o rendered_pages/man{{section}}/{/.}" \
    ::: markdown/*.md

@build section="ak": (setup section) (convert section)
    ls rendered_pages/man{{section}}
    [ "$(ls -l markdown/ | wc -l)" -eq "$(ls -l rendered_pages/man{{section}} | wc -l)" ]
    echo "add the line 'export MANPATH=\$(manpath):$(realpath rendered_pages)' to your .zshrc file" 
    echo "add 'export MANSECT={{all_sections}}:{{section}}' to your .zshrc"
    echo "also check ~/.zshenv"

# build & preview a single man page(without extension!)
preview name:
    man <(pandoc --standalone --to man markdown/{{name}}.1.md)

compress section="ak":
    echo "uncompressed data size is $(du -sh rendered_pages/man{{section}})"
    parallel 'gzip' ::: rendered_pages/man{{section}}/*
    echo "compressed data size is $(du -sh rendered_pages/man{{section}})"

uncompress section="ak":
    parallel 'uncompress' ::: rendered_pages/man{{section}}/*

clean:
    rm -vR rendered_pages/*