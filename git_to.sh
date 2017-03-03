
# in order to stage manually deleted files for commit:
git rm --ignore-unmatch $(git ls-files --deleted)

git add -A *.log *.apodder *.sh *.txt
 
git commit -m "$(date)"

git push --prune https://AlexCaseiro1979@github.com/AlexCaseiro1979/my_alxpodder.git
