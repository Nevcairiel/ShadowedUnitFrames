UPSTREAM := https://github.com/Nevcairiel/ShadowedUnitFrames.git
UPSTREAM_BRANCH := classic

.PHONY: setup update regen-patches

setup:
	git remote add upstream $(UPSTREAM) || true
	git fetch upstream $(UPSTREAM_BRANCH)

update:
	git fetch upstream $(UPSTREAM_BRANCH)
	git rebase upstream/$(UPSTREAM_BRANCH)
	git am patches/*.patch

regen-patches:
	git format-patch upstream/$(UPSTREAM_BRANCH) -o patches/ --no-stat
