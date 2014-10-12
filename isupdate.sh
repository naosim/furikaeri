before=`git log --pretty=format:"%h" -1`
git fetch
after=`git log --pretty=format:"%h" origin/master -1`
echo "before:$before"
echo "after :$after"

if test $before != $after; then
  echo updated! deploy start!
  exit 0
else
  echo no update
  exit 1
fi
