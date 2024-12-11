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
:   Verbose. Can be repeated up to 3 times to increase the level

`-f`
:   Archive's filename to Create/to eXtract. Must be the last arg?

`(--use-compress-program|-I)` *"COMPRESSOR OPTIONS..."* ...
:   Use a specific compressor program

`-C` *folder/to_extract/files/into*
:   specify the extraction folder(only with **(-x)** mode)

# COMPRESSORS/FORMATS/DECOMPRESSORS

Any option below with *COMPRESSOR*/*EXT* values can be substituted
with the following:

```{bash}
zstd->.zst->unzstd/(zstd -d)
xz->.xz->unxz/(xz -d)
bzip2->.bz2->bunzip2/(bzip2 -d)
lzma->.lzma->unlzma/(lzma -d)
gunzip->.gz->gunzip/(gzip -d)
lzip->.lz->unlzip
lzop->.lzo->unlzop/(lzop -d)
```

# Examples

## Compress

tar -\-*COMPRESSOR* \[*FOLDER*...] \[*FILE*...] -cvf *ARCHIVE*.tar.*EXT*
: compress files via a *COMPRESSOR* of choice using default *COMPRESSOR* params

`tar -I 'zstd -19 -T0' -cf directory.tar.zst directory/`
: Linux-only way to pass customs params to a compressor

`tar --use-compress-program "zstd -T0 -3" -cf "output.tar.zst" "input-directory/ file..."`
: Linux/OSX-comparable way to pass customs params to a compressor

## Decompress(eXtract)

tar \-\-*COMPRESSOR* -xvf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding compressor(convenient because you don't have to know *DECOMPRESSOR*)

tar --use-compress-program "*COMPRESSOR* -d" -xf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding "*COMPRESSOR* supporting **-d** option

`tar --use-compress-program "zstd -d" -xf "archive.tar.zst"`
: example of above

tar -\-use-compress-program=*DECOMPRESSOR* -xvf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding decompressor(ex. **unzstd**)
