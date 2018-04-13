Git Time Machine
================

The purpose of this shell script is to reset the entire Git repository to a specific date in the past.
This includes:

* Removing new tags
* Removing new branches
* Setting existing branches to the most recent commits before the date
* Running `git gc` and removing the Git objects which appeared after the date

This script requires:

* GNU coreutils, especially `sed` with `-i` argument incompatibe with BSD/macOS
* Bash
* Python3
* `dateutil` Python package (`pip3 install python-dateutil`)

## Usage

```
git clone https://github.com/whoever/whatever && cd whatever
date="Wed Feb 14 00:00:00 2018 -0800" ./git-time-machine.sh
```

Specify `master=...` environment variable if the main branch is not `master`.
**There should be no local branches except the main one.**

## Contributions

Porting this script to BSD/macOS and fixing bugs is welcome!

