#!/usr/bin/env bash

set -euo pipefail
cd "$(dirname "${0}")"
parallel --bar "pandoc --standalone --to man {} -o rendered_pages/{/.}" ::: markdown/*.md
cd -
