% Git(1) | General Commands Manual
% Alexander Khrulev(AlKhrulev \[at] GitHub)
% 2024-12-13

# NAME

A custom man page for **git**

# SYNOPSIS

# DESCRIPTION

A collection of useful git commands

# COMMON OPTIONS

# REVISION TYPES

https://git-scm.com/docs/gitrevisions

# Conflicts

## Markers

Conflict Markers
:    `<<<<<<<`, `=======`, and `>>>>>>>`

Changes made in the current branch
:   between `<<<<<<<` HEAD and `=======`

Changes from the incoming branch
:   between `=======` and `>>>>>>>` incoming_branch.

Common ancestor for both commits(displayed only in `diff3` style)
:   between `|||||||` and `>>>>>>>`(i.e. current and incoming branches)

## Examples

### **Merge** style

Supports only 2 file diff, so that's what shown

```{bash}
<<<<<<< HEAD
THIS IS USEFUL
=======
This is really useful
>>>>>>> c2392943.....
```

### **Diff3** style*(supports 3-file diffs)

```{bash}
<<<<<<< HEAD
THIS IS USEFUL
||||||| merged common ancestors
This is useful
=======
This is really useful
>>>>>>> c2392943.....
```

## Process

For each conflicting file, the makers will be added automatically. Then

1. Decide which changes to keep, modify, or discard.
2. Remove all conflict markers from the file
3. Run **git add *Filename***
4. Commit the changes

# Terminal Command Examples

## Displaying Files and Differences

### Viewing Commit Logs

`git log (--name-only|--name-status) ...`
:   don't list file changes in detail and only specify their names

`git log (--name-only|--name-status) --oneline ...`
:   Same as above but print only 1 line of commit message and not the whole thing

### Viewing Files

`git show` \[\[*Rev*]:\[*Object*]...]
:   Show the state of repo(or specific objects) at a particular *Rev*(**HEAD** by default). Uses a pager by default but can be redirected into a file. Ex. **git show HEAD:LICENSE HEAD^1:README.md > file**

`git diff` \[*Rev1*]:\[*Object1*] \[*Rev2*]:\[*Object2*]
:   Ex. compare 2 files **git diff HEAD^1:README.md HEAD:README.md** or two branches **git diff develop main**

`git diff (-w|--ignore-all-space) ...`
:   Ignore whitespaces both at EOL and inside of the text

`git diff --ignore-space-at-eol ...`
:   Ignore only EOL space diffs(i.e. trailing spaces)

## Working with Remotes

git remote add *Name* *URL*.git
:   add a new remote with a name. Ex. **git remote add origin https://github.com/OWNER/REPOSITORY.git**

git remote set-url *ExistingName* *URL*.git
:   Update remote's url

`git remote -v`
:   List all remotes

git remote rename *ExistingName* *NewName*

git remote (rm|show) *ExistingName*

git fetch \[*Remote*]/git push \[*Remote*] \[*Branch*]
:   Git implicitly inserts the remote info into your commands. Ex. **git fetch \[origin]**/**git push \[origin] \[current_branch]**

### Delete Local Branch

git branch -d *LocalBranchName*...
:   Delete fully merged branches(fails otherwise)

git branch -D *LocalBranchName* ...
:   Alias to `git branch -d --force`.
That is, delete a branch without checking that it has been merged

### Delete Remote Branch

git push -d *RemoteName* *RemoteBranchName*
:   Delete a remote branch. *RemoteName* is typically **origin**

git push *RemoteName* :*RemoteBranchName*
:   Delete a remote branch. Note there's a
space in-between *RemoteName* and a colon. Ex. **git push origin :serverfix**

`git fetch --all --prune`
:   Fetch the data from all remotes(**-\-all**) and automatically remove remote branches that don’t have a local counterpart. I.e. you will first need to manually remove local branches as well before pruning remotes on your machine.

git apply ... *PatchFile*
:   Apply a *PatchFile* to the current repo
