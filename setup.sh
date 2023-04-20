#!/bin/sh

# We now have these branches:
#                     A topic
#                    /
#               B---C---D main

# This script can re-create 3 scenarios
if [ $# -eq 0 ]; then
    echo "Please provide a number 1, 2 or 3:"
    echo ""
    echo "  sh $0 1"
    echo ""
    echo "Each number will prepare a specific scenario for you to try."
    echo "This will *destroy* your local remote location."
    echo
    echo "1:"
    echo "Both your local and the remote have commits."
    echo "Trying to pull from the remote will result in an unresolved merge."
    echo
    echo "2:"
    echo "Your local has uncommitted changes and the remote has commits."
    echo "Trying to pull from the remote will result in an unresolved merge."
    echo
    echo "3:"
    echo "Both your local and the remote have commits."
    echo "Trying to push to the remote will result in an error."
    exit 1
fi

case $1 in
    1|2|3)
	option=$1
	;;
    *)
	echo "Unknown option? $1"
	exit 1
	;;
esac

# Create a new clone of this repo
rem=$(git remote get-url origin)
dir=$(pwd)/fake_remote
if [ ! -d $dir ]; then
    # just create a clone
    git clone $rem $dir
    (
	cd $dir
	git checkout topic
	# 1: we move topic to main1
	git branch main1 topic
	# 2: we move topic to main2
	git branch main2 topic
	# 3: we move main~1 into main3
	git branch main3 main~1
	git checkout main
    ) > /dev/null 2>/dev/null
    echo "Done setting up the fake remote repository"
fi

if ! git remote show host >/dev/null 2>/dev/null ; then
    # ensure the remote exists
    git remote add host $dir
    git fetch host
fi

# 1.
# You are trying to pull down a remote that has commits and you have too
#  git switch main
#  git pull host
if [ $option -eq 1 ]; then
    # run things locally
    git branch main1 main
    git switch main1
    git branch -u host/main1 main1

    echo ""
    echo "Now run:"
    echo "  git pull host"
    echo "And to see why it happened:"
    echo "  git status"
fi


# 2.
# You are trying to pull down a remote where you have local uncommitted
# changes.
#  git switch main
#  echo "" >> file
#  git commit ...
#  git push host
if [ $option -eq 2 ]; then
    # run things locally
    git branch main2 main
    git switch main2
    git branch -u host/main2 main2
    echo ""
    echo "Now run:"
    echo "  git push host"
    echo "And to see why it happened:"
    echo "  git status"
fi


# 3.
# You are trying to pull commits but you have local uncommitted changes
#  git switch main
#  echo "" >> file
#  git pull host
if [ $option -eq 3 ]; then
    # run things locally
    git branch main3 main~1
    git switch main3
    git branch -u host/main3 main3
    echo "Adding something to src/source_2.py"
    echo "erroneous edit: " >> src/source_2.py
    
    echo ""
    echo "Now run:"
    echo "  git pull host"
    echo "And to see why it happened:"
    echo "  git status"
fi




