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

# Examples

`git log --name-only/--name-status ...`
:   don't list file changes in detail and only specify their names

`git log --name-only/--name-status --oneline ...`
:   Same as above but print only 1 line of commit message and not the whole thing

`git show` \[\[*Rev*]:\[*Object*]...]
:   Show the state of repo(or specific objects) at a particular *Rev*(**HEAD** by default). Uses a pager by default but can be redirected into a file. Ex. **git show HEAD:LICENSE HEAD^1:README.md > file**

`git diff` \[*Rev1*]:\[*Object1*] \[*Rev2*]:\[*Object2*]
:   Ex. compare 2 files **git diff HEAD^1:README.md HEAD:README.md** or two branches **git diff develop main**

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

git branch -d *LocalBranchName*...
:   Delete fully merged branches(fails otherwise)

git branch -D *LocalBranchName* ...
:   Alias to `git branch -d --force`.
That is, delete a branch without checking that it has been merged

git push -d *RemoteName* *RemoteBranchName*
:   Delete a remote branch. *RemoteName* is typically **origin**

git push *RemoteName* :*RemoteBranchName*
:   Delete a remote branch.Note there's a
space in-between *RemoteName* and a colon. Ex. **git push origin :serverfix**

`git fetch --all --prune`
:   Fetch the data from all remotes and automatically remove remote branches that don’t have a local counterpart. I.e. you will first need to manually remove local branches as well before pruning remotes on your machine.


