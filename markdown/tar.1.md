% Tar(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-07

# NAME

Tar

# SYNOPSIS

TODO

# DESCRIPTION

A collection of useful Tar commands

# COMMON OPTIONS

## Modes

`-(c|x|t)`
:   **C**reate/e**X**tract/**T**est(files inside+sizes) an archive

## To be Combined with Modes

`-v`
:   Verbose

`-f`
:   Archive's filename to Create/to eXtract. Must be the last arg?

`(--use-compress-program|-I)` *"COMPRESSOR OPTIONS..."* ...
:   Use a specific compressor program

# COMPRESSORS

Any option below with *COMPRESSOR*/*EXT* values can be substituted
with the following:

```{bash}
zstd->.zst
xz->.xz
bzip2->.bz2
lzma->.lzma
gunzip->.gz
lzip->.lz
lzop->.lzo
```

# Examples

tar \-\-*COMPRESSOR* \[*FOLDER*...] \[*FILE*...] -cvf *ARCHIVE*.tar.*EXT*
: compress files via a *COMPRESSOR* of choice

`tar --COMPRESSOR [FOLDER...] [FILE...] -xvf ARCHIVE.tar.EXT`
: decompress files via a *COMPRESSOR* of choice`

`tar -c -I 'zstd -19 -T0' -f directory.tar.zst directory/`
: Linux-only way to pass args to a compressor

`tar --use-compress-program "zstd -T0 -3" -cf "output.tar.zst" "input-directory/ file..."`
: Linux/OSX-comparable way to pass args to a compressor

`tar --use-compress-program "zstd -d" -xf "archive.tar.zst"`
: universal way to decompress

`tar --use-compress-program=(unzstd|...) -xvf archive.tar.zst`
: decompress via a corresponding decompressor

tar \-\-*COMPRESSOR* -xvf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding decompressor
