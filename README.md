Reproducible research
---------------------

How to ensure a reproducible research output while
simultaneously developing and gathering data.

This project has two branches used for testing purposes.

The following explantions refer to how a project maintainer
would consider the branches and their relationship.

The current commit history looks like this:
```
          A topic
         /
... B---C---D main
```


## [main]

This branch is the development branch and where every
development goes into.

This branch has 1 commit that the [topic] branch does not have.


## [topic]

Branch with some feature development. This branch is diverging
its development from the [main] branch.

This branch has 1 commit that the [main] branch does not have.


### Difference using `git diff`

Using `git diff` is an important command when mastering ones development
process.

| `git diff <>` | Description |
|---------------|-------------|
| <nothing>     | between staged and unstaged changes|
| `--staged`    | between `HEAD` and staged changes |
| `<1>..<2>`    | a patch that can be applied to `<1>` to be equivalent to `<2>` |
| `<1>...<2>`   | what has been added to `<2>` since `<1>` and `<2>` had a common ancestor |


The difference of the last two are shown below in 4 examples.

- `git diff topic..main`

  ```patch
  diff --git a/src/source_2.py b/src/source_2.py
  index ca55c68..8ba15bc 100644
  --- a/src/source_2.py
  +++ b/src/source_2.py
  @@ -1,5 +1,5 @@
   def foo():
       print("foo")

  -def foo2():
  -    print("foo2")
  +def foo_other():
  +    print("foo_other")
  ```

- `git diff topic...main`

  Note the extra "."!

  ```patch
  diff --git a/src/source_2.py b/src/source_2.py
  index af3cbda..8ba15bc 100644
  --- a/src/source_2.py
  +++ b/src/source_2.py
  @@ -1,2 +1,5 @@
   def foo():
       print("foo")
  +
  +def foo_other():
  +    print("foo_other")
  ```

- `git diff main..topic`

  ```patch
  diff --git a/src/source_2.py b/src/source_2.py
  index 8ba15bc..ca55c68 100644
  --- a/src/source_2.py
  +++ b/src/source_2.py
  @@ -1,5 +1,5 @@
   def foo():
       print("foo")

  -def foo_other():
  -    print("foo_other")
  +def foo2():
  +    print("foo2")
  ```

- `git diff main...topic`

  Note the extra "."!

  ```patch
  diff --git a/src/source_2.py b/src/source_2.py
  index af3cbda..8ba15bc 100644
  --- a/src/source_2.py
  +++ b/src/source_2.py
  @@ -1,2 +1,5 @@
   def foo():
       print("foo")
  +
  +def foo2():
  +    print("foo2")
  ```


## Tutorial 1

Execute `sh setup.sh 1` from the commandline (requires BASH/Unix) and follow instructions
from the output.  
The following elements describe the situation in more detail.

In tutorial 1 we will examine what happens when you try to `git pull` a remote branch
which has diverged from your own commits.

The commit branch looks like this:
```
... A---B---C  [remote]
    |   |
... A---B---D  [local]
```
Or as though they were local commits:
```
          C [remote]
         /
... A---B---D [local]
```

Pulling will try to update the current branch's commits to match the ones on the remote.

This will fail since both repositories have a commit meaning that there is no linear history.


With `git` there are always multiple ways of doing things.

### Resolution 1 -- manual rebase

Generally one cannot push to remotes as they are "protected" by some admin user.  
The only solution is to backtrack ones changes and re-apply the changes to have a linear
history.

In this case we know that *we* have 1 additional commit that the remote does not have.
So we can do:
```shell
git diff HEAD~1 > our_commit.patch
git reset --hard HEAD~1
git pull host
# <manually go through our_commit.patch and add the content
# You can try
#  patch -p1 < out_commit.patch
# but it will fail since it affects the same lines as was pulled from host.
# So manual labor is necessary.
# Once completed, do:
git commit -am "[main]: updated source_2"
```


### Resolution 2 -- manual rebase, patch-handlings

This procedure is equivalent to the above, but takes advantage of internal `git`
commands:
```shell
git format-patch HEAD~1
git reset --hard HEAD~1
git pull host
git am .
```


### Resolution 3 -- direct rebase

A direct rebase will do the above commands in a *smart* way by letting you
change things if conflicts happen. Its use is somewhat magical and one should carefully
look at the output of `git` commands to see how to proceed. For instance, problems
will result in users needing to intervene and correct merge conflicts, then `git add`,
then `git rebase --contine`.

If things goes completely bad, one can always abort by doing `git rebase --abort` to
revert everything that has been done in the `rebase` command.

This is, probably the easiest way in the long-term, but can be quite hard when rebasing
many commits with large conflicts.

This procedure is started with:
```shell
git rebase host/main1
```
and simply do what it says.


### Resolution 4 -- merge

In this case a merge will not be applicable since the branches are *meant* to be coherent (i.e. every
commit needs to be 1-1).  
A merge would result in the local branch having a different history from the remote, although the content
would be the same. Thus meaning that you would never be able to push from this branch.


## Tutorial 2

Execute `sh setup.sh 2` from the commandline (requires BASH/Unix) and follow instructions
from the output.  
The following elements describe the situation in more detail.

This is the same scenario as in 1, but you were trying to do a `push` (instead of `pull`) to the remote.
The resolutions are the same as in Tutorial 1, but in Resolution 3, replace `host/main1` with `host/main2`.

One should appreciate that the resolution is often the same procedure, since it all boils down to *differing commits*.
Any resolution can often done by aligning commits (if merge is not an option).  


## Tutorial 3

Execute `sh setup.sh 3` from the commandline (requires BASH/Unix) and follow instructions
from the output.


