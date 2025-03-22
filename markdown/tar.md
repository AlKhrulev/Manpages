% Tar(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-07

# NAME

A custom man page for **GNU tar**

# SYNOPSIS

## UNIX-Style Usage

```
tar -c [-f ARCHIVE] [OPTIONS] [FILE...]
tar -d [-f ARCHIVE] [OPTIONS] [FILE...]
tar -r [-f ARCHIVE] [OPTIONS] [FILE...]
tar -u [-f ARCHIVE] [OPTIONS] [FILE...]
tar -t [-f ARCHIVE] [OPTIONS] [MEMBER...]
tar -x [-f ARCHIVE] [OPTIONS] [MEMBER...]
```

# DESCRIPTION

A collection of useful Tar commands

# COMMON OPTIONS

## REQUIRED FLAGS

`-(c|x|t|d)`
:   **C**reate/e**X**tract/**T**est(files inside+sizes)/**D**elete (from) an archive. Specifying some sort of *COMPRESSOR* flag is mandatory only for **-c**

`-u`
:   Adds the files specified by one or more File parameters to the end of the archive only if the files are not in the archive already, or if they have been modified since being written to the archive. Tar cannot update compressed archives

`-r`
:   Writes the files specified by one or more *File* parameters to the end of the archive. Tar cannot update compressed archives

## OPTIONAL FLAGS

`-v`
:   Verbose. Can be repeated up to 3 times to increase the level

`-f` *ARCHIVE.tar.EXT*
:   Uses the ARCHIVE as the archive to be read or written.

`(--use-compress-program|-I)` *"COMPRESSOR OPTIONS..."* ...
:   Use a specific compressor program

`-C` *DIRECTORY*
:   Causes the tar command to perform a **chdir** subroutine to the directory specified by the Directory variable. Ex. **tar c -C /usr/include File1 File2 -C /etc File3 File4**. Must appear after all other flags.

`-w`
:   Displays the action to be taken, followed by the file name, and then waits for user confirmation. If the response is affirmative, the action is performed. If the response is not affirmative, the file is ignored.

`-L` *InputList*
:   Writes the files and directories listed in the *InputList* variable to the archive. Directories from the **InputList** variable are not treated recursively. For directories contained in the *InputList* variable, the tar command writes only the directory to the archive, not the files and subdirectories rooted in the directory.

# COMPRESSORS/FORMATS/DECOMPRESSORS

Any option below with *COMPRESSOR*/*EXT* values can be substituted
with the following:

```
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

`tar -czvf archive.tar.gz -C Manpages LICENSE -C sample_folder README.md`
:   Doesn't work cause **sample_folder** is not inside of **Manpages** folder

`tar -czvf archive.tar.gz -C Manpages LICENSE -C ~/Downloads/sample_folder README.md`
:   **chdir** to **Manpages** and **tar LICENSE**, then **chdir** to **~/Downloads/sample_folder** and **tar README** and then create an archive in the initial working directory

tar -acf **ArhiveName.tar.ext** -C **FolderName** .
:   Compress all files in **FolderName**

Say `~/Downloads/sample_folder` has files f1, f2, inner/f3.

`tar -czvf archive.tar.gz -C ~/Downloads/sample_folder .`
:   Adds f1, f2, inner/f3 to `archive.tar.gz`

`tar -czvf archive.tar.gz -C ~/Downloads/sample_folder *`
:   Works incorrectly cause * gets expanded before chdir!!!

`tar -czvf archive.tar.gz ~/Downloads/sample_folder`
:   Preserves paths and archives ~/Downloads/sample_folder/{f1,f2,inner/f3}

## Decompress(eXtract)

tar \-\-*COMPRESSOR* -xvf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding compressor(convenient because you don't have to know *DECOMPRESSOR*)

tar --use-compress-program "*COMPRESSOR* -d" -xf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding "*COMPRESSOR* supporting **-d** option

`tar --use-compress-program "zstd -d" -xf "archive.tar.zst"`
: example of above

tar -\-use-compress-program=*DECOMPRESSOR* -xvf *ARCHIVE*.tar.*EXT*
: decompress via a corresponding decompressor(ex. **unzstd**)

tar -xf *ARCHIVE* -C *EXISTING_DIR*
: extract the content into the *EXISTING_DIR*(fails if not present)
