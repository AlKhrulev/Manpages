% Tar(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-07

# NAME

Tar

# SYNOPSIS

TODO

# DESCRIPTION

A collection of useful Tar commands

# Examples

`tar -c -I 'zstd -19 -T0' -f directory.tar.zst directory/`
: Linux-only way to pass args to a compressor

`tar --use-compress-program "zstd -T0 -3" -cf "output.tar.zst" "input-directory/ file..."`
: Linux/OSX-comparable way to pass args to a compressor

`tar --use-compress-program "zstd -d" -xf "archive.tar.zst"`
: universal way to decompress
