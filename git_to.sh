
# in order to stage manually deleted files for commit:
git rm $(git ls-files --deleted)

git add -A *.log *.apodder *.sh *.txt
 
git commit -m "$(date)"

git push --prune
