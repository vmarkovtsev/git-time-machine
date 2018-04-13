#!/bin/bash -e

date=$date
if [ -z "$date" ]; then
  date="Wed Feb 14 00:00:00 2018 -0800"
fi
master=$master
if [ -z "$master" ]; then
  master=master
fi

function must_save {
    if [ $2 == "branch" ]; then
    fork_point=$(diff -u <(git rev-list --first-parent $1) <(git rev-list --first-parent $master) | sed -ne 's/^ //p' | head -1)
    else
    fork_point=$1
    fi
    fork_date=$(git log -1 --format='%cd' "$fork_point" 2>/dev/null)
    if [ $? != 0 ]; then
      echo 1
      return
    fi
    echo $fork_date | python3 -c "from dateutil import parser
import sys
sec = (parser.parse(input()) - parser.parse("$date")).total_seconds()
sys.exit(sec < 0)"
    echo $?
}

for tag in $(git tag); do
save=$(must_save $tag tag)
if [ $save == "0" ]; then
delexpr="/$(echo $tag | sed 's/\//\\\//g')/d"
sed -i "$delexpr" .git/packed-refs
echo $tag '[REMOVED]'
fi
done

for branch in $(git branch -a | grep -vE -- '->|\*'); do
if [ $branch == "remotes/origin/$master" ]; then
  save=1
else
  save=$(must_save $branch branch)
fi
if [ $save == "0" ]; then
delexpr="/$(echo $branch | sed 's/\//\\\//g')$/d"
sed -i "$delexpr" .git/packed-refs
echo $branch [REMOVED]
else
old_head=$(git log --format="%H" $branch | head -1)
new_head=$(git log --before "$date" --format="%H" $branch | head -1)
if [ -z $old_head ]; then
    continue
fi
if [ $old_head != $new_head ]; then
    delexpr="/$(echo $branch | sed 's/\//\\\//g')$/d"
    sed -i "$delexpr" .git/packed-refs
    echo "$new_head refs/$branch" >> .git/packed-refs
    echo $branch "[$old_head > $new_head]"
fi
fi
done

git checkout -b kill_new_git
git branch -D $master
git checkout -t remotes/origin/$master
git branch -D kill_new_git
git reflog expire --expire-unreachable=now --all
git gc --aggressive --prune=now
