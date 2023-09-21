#!/bin/bash

# rename branch
git checkout $OLD_BRANCH
git branch -m $NEW_BRANCH
git push origin -u $NEW_BRANCH
git push origin --delete $OLD_BRANCH
git branch -D $OLD_BRANCH

# git alias
git config --global alias.pr pull-request

# git squash
git log --graph --decorate --pretty=oneline --abbrev-commit
git log .
git rebase -i HEAD~[NUMBER OF COMMITS] OR git rebase -i $SHA_OF_FIRST_BRANCH_COMMIT
# you choose the first commit with pick(p) and the rest you choose squash(s) drop(d) or fixup (f)
# rework the commit messages and finally:
git push origin branchName --force

# git rebase
git checkout master
git pull
git checkout feature branch
git rebase master
git checkout master
git rebase feature branch

# new GitHub repo
git init
git branch -m main
git add -A
git commit -m 'initial commit'
git remote add origin git@github.com:username/reponame.git
git push -u -f origin main

# git stash
git stash
git stash push -m “Working with stash”
# A stash is not bound to a certain branch. When you restore it at a later point, 
# all changes will be applied to the current HEAD branch, no matter where that is.
git stash list
git stash show stash@{1}
git checkout stash@{0}
git stash drop
git stash branch branch-name
git stash pop

# git lfs
git lfs track
git lfs track data/large-file.csv
git lfs migrate import --no-rewrite -m "Import test.zip, .mp3, .psd files in root of repo"  test.zip *.mp3 *.psd
git lfs migrate import --everything --above=40MB
git lfs migrate import --everything --include="*.zip,*.pkl,data/db_pipeline/**/*,src/spend/**/*,src/lab_pfr/**/*,src/lab_ebi/**/*,visualization/shinyApp/**/*"
git lfs migrate import --everything --above=40MB

# git autopack feature
git gc --auto
git gc --prune=now

# merge unrelated history
git pull origin master --allow-unrelated-histories
git merge origin origin/master
git add .
git commit -m "test"
pit push origin master

# git merge
git merge branch-name
git merge --squash branch-name

# remove files from history
git filter-branch --index-filter "git rm -rf --cached --ignore-unmatch path_to_file" HEAD

# clean untracked files
git clean -df

# git statuses and logs
git log
git status
git log --oneline
git reflog
git log --stat

# git revert
git revert COMMIT_HASH
git revert HEAD~2..HEAD
git revert -m 1 MERGE_COMMIT_SHA

# git advanced commands
git whatchanged
git worktree
git cherry-pick

# rename branch
git branch -D old-branch
git branch -m new-branch
git push -f origin new-branch
git gc --aggressive --prune=all  