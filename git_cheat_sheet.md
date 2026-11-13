# Git cheat sheet: combining pieces of different commits

Each commit is a saved snapshot you can copy pieces from.
Do all of this on a fresh branch (`git switch -c clean`) so you can throw it away if it goes wrong.

## Look before you take

```
git log --oneline --graph --all     # see the commits
git show --stat <commit>            # which files that commit touched
```

## 1. Whole commits: `cherry-pick`

```
git cherry-pick <A> <B> <C>         # copy those commits onto the current branch
git cherry-pick <A>^..<C>           # a range, A through C
```

On a conflict: fix the files, `git add` them, then `git cherry-pick --continue`.

## 2. Only some files from a commit: `restore`

```
git restore --source=<commit> -- Sources/ Tests/
```

Copies those paths as they were in that commit into your working tree.
It copies the file state, not the commit's changes. Deleted files need a separate `git rm`.

## 3. Only some pieces of a file: `restore -p`

```
git restore -p --source=<commit> -- path/to/file.swift
```

Asks about each changed chunk: `y` takes it, `n` skips it.

## 4. Part of a commit: cherry-pick without committing

```
git cherry-pick -n <commit>                     # apply the changes, don't commit
git restore --staged --worktree ProjectCore/    # drop the parts you don't want
git commit
```

## 5. Cleaning up your own branch: `rebase -i`

```
git rebase -i <base>
```

Mark each commit in the list:

- `drop`: remove the commit
- `squash` / `fixup`: merge into the commit above
- reorder the lines to reorder the commits
- `edit`: stop at a commit so you can split it (`git reset HEAD^`, stage pieces with `git add -p`, make several smaller commits)

Only rebase commits nobody else has pulled. Otherwise use cherry-pick or `git revert <commit>`, which add new commits instead of rewriting old ones.

## 6. Whole branches: `merge`

```
git merge <branch>
```

Joins the histories and keeps every commit.

## Worked example (this repo)

Start from the last good commit and bring back only what you want:

```
git switch -c clean 8dc5bd6
git restore --source=db5e30a -- Sources Tests
git rm -r Features Models Services     # the old locations
git commit -m "Move code into Sources/"
```

Keeps the Sources move and leaves out `ProjectCore/`, the root `Package.swift`, `PROJECT.md`, `TICKET.md` and the `five-fixes.patch` deletion. Any of those can be pulled back the same way.

## If you mess up

`git reflog` lists every place HEAD has been. Then:

```
git reset --hard <that-entry>
```
