set shell := ["zsh", "-uc"]
# default system section name string separated by ":"
all_sections := `grep '^SECTION' /etc/manpath.config | tr -s ' \t' ':' | cut -d ":" -f2-`
alias p := preview
alias b := build

# verify if necessary dependencies are present
[group("utils")]
@verify_dependencies:
    command -v parallel > /dev/null
    command -v pandoc > /dev/null

# mkdir for a corresponding section name
[group("utils")]
mkdir section="ak":
    mkdir -p "rendered_pages/man{{section}}" 2> /dev/null

# convert all markdown files into man pages
[group("build")]
convert section="ak": verify_dependencies
    parallel -q \
    pandoc --standalone --to man {} -o rendered_pages/man{{section}}/{/.}.{{section}} \
    ::: markdown/*.md
    # automatically update doc's date to today(use a variable for clarity)
    TODAY="$(date +%Y-%m-%d)" && \
    parallel -q \
    sed -i "3s/[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}/${TODAY}/" \
    ::: rendered_pages/man{{section}}/*

# set up a file structure and convert all markdown files into man pages
[group("build")]
@build section="ak": (mkdir section) (convert section)
    ls rendered_pages/man{{section}}
    [ "$(ls -l markdown/ | wc -l)" -eq "$(ls -l rendered_pages/man{{section}} | wc -l)" ]
    echo "add the line 'export MANPATH=\$(manpath):$(realpath rendered_pages)' to your .zshrc file" 
    echo "add 'export MANSECT={{all_sections}}:{{section}}' to your .zshrc"
    echo "also check ~/.zshenv (if you use zsh)"

# build & preview a single man page(without extension!)
[group("build")]
preview markdown_file:
    man <(pandoc --standalone --to man markdown/{{markdown_file}}.md)

# compress man pages into .gz files
[group("working with man page files")]
compress section="ak":
    @echo "uncompressed data size is $(du -sh rendered_pages/man{{section}})"
    parallel 'gzip -v9' ::: rendered_pages/man{{section}}/*
    @echo "compressed data size is $(du -sh rendered_pages/man{{section}})"

# uncompress man pages
[group("working with man page files")]
uncompress section="ak":
    parallel 'uncompress' ::: rendered_pages/man{{section}}/*

# remove all created files and folders
[group("utils")]
clean:
    rm -vR rendered_pages/*