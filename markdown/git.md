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

## Displaying Info

`git rev-parse [--short] HEAD`
:   print commit SHA [short] of HEAD

`git rev-parse [--short] FETCH_HEAD`
:   print commit SHA [short] of FETCH\_HEAD

git show-branch *BranchName*
:   print HEAD of *BranchName*

## Modifying file state

git checkout=git restore + git switch

git checkout -- *FileName*
:   identical to `git restore --staged --worktree`

git reset -- *FileName*
:   identical to `git restore --staged --`

git restore --staged -- *FileName*
:   unstage file but keep it unchanges(restore index)

git restore [--worktree] -- *FileName*
:   overwrites *FileName* in your working copy with the contents in your index. Works only if file is not staged!!

git restore --worktree --staged -- *FileName*
:   unstage *FileName* and set it to the state in HEAD

git restore --source=HEAD --staged --worktree *FileName*
:   outdated way to do the previous command, HEAD had to be explicit(now, we default to HEAD when combining --staged and --worktree)

`git restore -p ...`
:   restore selected parts...


## Working with Commits

`git add -i`
: enable interactive mode. See `man git-add`->`INTERACTIVE MODE` for more info

`git add --patch`
:   essentially a shortcut to `git add -i`->`patch`

git commit -\-squash *COMMIT*
:   indicate that you want to squash a commit for `rebase --autosquash`. Use commit, but meld into previous commit. I.e. in this case both commit messages are combined ('melded'), one after the other, and offered to the user's editor, so that they can be amalgamated/fused together as desired by the user.

git commit -\-fixit *COMMIT*
:   indicate that you want to squash a commit for `rebase --autosquash`. Like "squash", but discard this commit's log message(in favour of *COMMIT* one's). I.e. the original commit message is kept, unchanged, and any text within the fixup commit message is ignored (unceremoniously dumped).

`git commit --amend [--no-edit]`
:   Add files to the previous commit and optionally keep the same msg

git commit --template *FileName*
:   Use text from *FileName* to start from

git commit --file *FileName*
:   Use text from *FileName* as a commit message

## Modifying Commit History

### Rebase vs Interactive Rebase

Taken from [this question](https://stackoverflow.com/questions/49626717/what-is-the-difference-between-interactive-rebase-and-normal-rebase)

**Rebase**
:   Does not take any user input so it picks all the commit from the branch without any amendment and applies all of it.

**Interactive Rebase**
:   It opens the editor in front of you so that we can do any kind of amendment for each commits in whatever way we want. Example:

```{bash}

pick <commit_hash> <commit_message>
pick 42522f0 add stack implementation

# Rebase 6aa416b..42522f0 onto 6aa416b (1 command)
#
# Commands:
# p, pick <commit> = use commit
# r, reword <commit> = use commit, but edit the commit message
# e, edit <commit> = use commit, but stop for amending
# s, squash <commit> = use commit, but meld into previous commit
# f, fixup <commit> = like "squash", but discard this commit's log message
# x, exec <command> = run command (the rest of the line) using shell
# b, break = stop here (continue rebase later with 'git rebase --continue')
# d, drop <commit> = remove commit
# l, label <label> = label current HEAD with a name
# t, reset <label> = reset HEAD to a label
# m, merge [-C <commit> | -c <commit>] <label> [# <oneline>]
# .       create a merge commit using the original merge commit's
# .       message (or the oneline, if no original merge commit was
# .       specified). Use -c <commit> to reword the commit message.
#
# These lines can be re-ordered; they are executed from top to bottom.
#
# If you remove a line here THAT COMMIT WILL BE LOST.
#
# However, if you remove everything, the rebase will be aborted.
```

### Squashing

You squash later commits into earlier ones!

`A->B->C, C=HEAD`
:   Can squash C->B, B->A, not reverse.


### Commands

git rebase *CommitHash*^
:   rebase from *CommitHash*(inclusive). Typically what you want

`git rebase ... --autosquash`
:   Take advantage of *squash* or *fixit* commits done before for autosquashing

git rebase \[-i] *BranchName*
:   Apply all commits from the current branch onto *BranchName*. When you rebase a branch, you are essentially replaying all the commits of the branch onto another base commit or branch.(ex. **git checkout feature-branch && git rebase main**)

git rebase \[-i] *CommitRange*
:   Rebase a range of commits(ex. **git rebase -i HEAD~5**)

git rebase \[-i] *BaseCommitSHA*
:   Rebase all commits **after**  *BaseCommit* up to the current HEAD

git rebase ... --\exec "*COMMAND*"
:   execute command after each line that created a commit in final history. If *COMMAND* fails, rebase fails as well. Useful to test intermediate commits(ex. **--exec "make build && make run"** to check if everything builds correctly)

git (add|rm) *FileWithConflict*...
:   Mark conflicts as resolved(edit Conflict markers in *FileWithConflict* first)

`git rebase --continue`
:   Use after fixing the conflict to continue the process

`git rebase --abort`
:   Terminate rebase and return to the state before it has started

`git push --force`
:   Push updated history to remote

`git rebase --signoff ...`
:   to add **Signed-off-by** footers to a range of commits

git rebase --exec "git commit --amend --no-edit -n -S" -i *GitRevision*
:   sign older commits via rebasing

`git fetch && git reset origin/main --soft`
:   Update commit history locally after remote branch(here *origin/main*) was force pushed but leave files intact

## Displaying Files and Differences

### Viewing Commit Logs

`git log (--name-only|--name-status) ...`
:   don't list file changes in detail and only specify their names

`git log (--name-only|--name-status) --oneline ...`
:   Same as above but print only 1 line of commit message and not the whole thing

`git log -p ...`
:   Display commit content as well

`git log --stat ...`
:   Add summary of file modifications

`git log --show-signature ...`
:   Show GPG signature of commits

`git log --abbrev-commit ...`
:   Use shortened commit SHA instead of a full one

### Viewing Files

`git show` \[\[*Rev*]:\[*Object*]...]
:   Show the state of repo(or specific objects) at a particular *Rev*(**HEAD** by default). Uses a pager by default but can be redirected into a file. Ex. **git show HEAD:LICENSE HEAD^1:README.md > file**

`git diff` \[*Rev1*]:\[*Object1*] \[*Rev2*]:\[*Object2*]
:   Ex. compare 2 files **git diff HEAD^1:README.md HEAD:README.md** or two branches **git diff develop main**

`git diff (-w|--ignore-all-space) ...`
:   Ignore whitespaces both at EOL and inside of the text

`git diff --ignore-space-at-eol ...`
:   Ignore only EOL space diffs(i.e. trailing spaces)

### Determining Who Made Changes

git blame -L 1,2 -L 8,11 \[-L ...\]
:   Find who made the changes for multiple lines

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

`git branch -vv`
:   Display all branches alongside their remote counterparts

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

git apply ... \[-\-include="*FilePattern*"] \[-\-exclude="*FilePattern*"] *PatchFile*
:   apply hunks only to specific files based on the include/exclude filename patterns

`filterdiff ...`
:   External command that let's you specific hunks for a patchfile

## Tags

Tag references are added to `refs/tags/`

### Commands

`git [-l] tag`
:   List all tags

git tag *TagName* \[*Commit*]
:   Add a tag pointing to *Commit*(`HEAD` by default)

git tag -a *TagName* ...
:   Add annotated(i.e. with a message) tag

git tag -v *TagName*
:   Output *TagName* message, author, signature

git tag -f *TagName* ...
:   Replace (existing) *TagName* instead of failing

git push *RemoteName* *TagName*
:   Push commit to remote. Ex. `git push origin v1.0.0`

git show *TagName*
:   Display tag info + message(if annotated)

git show-ref --tags *TagName*
:   Show what commit *TagName* points to

## Verifying Objects

git verify-(commit|tag|pack) *Object*
:   Print `only signatures` of a particular object type(Commit/Tag/Packfile)

## Going Into Internals

### Definitions

.git/index
:   a binary file containing index

*Reference(Ref)*
:   A pointer to a commit graph. View via *git reflog*

### Commands to Help with Viewing Internals

git show-branch *BranchName*
:   Get the commit description for the HEAD of *BranchName*

git rev-list *Ref*
:   show all commits from HEAD to *Ref*(goes down!)

git log *Ref*
:   show all commits from *Ref* to HEAD(goes up!)

git rev-parse *Ref*
:   Get the commit SHA for *Ref*(branch name, HEAD, tag, etc.)

git name-rev *Commit*
:   Get *Ref* for the required *Commit*

git cat-file -t *SHA*
:   Return *SHA* type(commit/tree/blob)

git cat-file -p *SHA*
:   Print the content of a blob or tree object with *SHA*. Blobs are stored in *.git/objects*(if unpacked) or *.git/packed/\*.pack* file if packed

git verify-pack -v *Pack*
:   View pack file content

