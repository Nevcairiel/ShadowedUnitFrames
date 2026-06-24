# Intro
This is a downstream repository from Nevcairiel/ShadowedUnitFrames, intended to provide fixes and features that the upstream repo cannot or will not provide. See the .patch files in patches/ for a list of features and bug fixes.

# How to use
To use this downstream distribution of ShadowedUnitFrames, run the following commands:
```
git clone https://github.com/bjthompson805/ShadowedUnitFrames
cd ShadowedUnitFrames
make setup
make update
```
Then, copy the folder into your WoW addons folder.

This will fetch the upstream repo and then apply the patches from this repo on top, one by one. If any patch fails to be applied due to recent upstream changes, it will notify you, but because of the way patches are (or should be) implemented, this will not break the addon, and the feature/bug-fix that the patch provides will simply not be there.

This patching method is much better than 'git rebase' (which tries to add commits on top of upstream's commits) because any failure would completely break the build and make it unusable.

