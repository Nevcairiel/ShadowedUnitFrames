# ShadowedUnitFrames (Classic/TBC Fork)

> This is a personal fork of [Nevcairiel/ShadowedUnitFrames](https://github.com/Nevcairiel/ShadowedUnitFrames), maintained to keep the addon working on **WoW Classic Era / TBC Classic Anniversary** realms.

## Why this fork exists

The original ShadowedUnitFrames (SUF) addon appears to be largely unmaintained upstream. Meanwhile, Blizzard periodically updates the Classic/TBC Anniversary client, and those client updates sometimes remove or change global APIs that SUF depends on (unit aura lookups, debuff color tables, protected-function call timing during combat, and similar). When that happens, the addon can throw Lua errors or stop working correctly until it's patched.

This fork exists purely to keep the addon **functional** on the Classic/TBC Anniversary realms as the client evolves — it is **not** intended to add new features, change the addon's design, or diverge from upstream's intent. Think of it as a compatibility patch stream rather than a new project.

## Scope of maintenance

- Focus: bug fixes and compatibility fixes caused by WoW Classic/TBC client API changes.
- Out of scope: new features, UI/UX redesigns, or functionality not present in the original addon.
- Target: WoW Classic Era and TBC Classic Anniversary realms only. Retail compatibility is not a goal of this fork.

If you're looking for new features or active feature development, please refer to the upstream project or its active successors/community forks instead.

## Attribution

All original design, functionality, and the vast majority of the codebase belong to the original author, **Shadowed**, and the upstream maintainer, **[Nevcairiel](https://github.com/Nevcairiel)**. This fork only contains targeted, minimal patches on top of that work to address breakage introduced by client-side API changes.

- Upstream repository: https://github.com/Nevcairiel/ShadowedUnitFrames
- Upstream addon page: https://www.wowace.com/projects/shadowed-unit-frames
- Please respect the license terms of the upstream repository. Refer to the upstream repository's `LICENSE` file for the applicable terms; this fork does not alter the original licensing.

## Installation

1. Download or clone this repository.
2. Copy the `ShadowedUnitFrames` (and `ShadowedUF_Options`, if present) folders into your WoW `Interface/AddOns` directory.
3. Make sure there isn't a nested extra folder level (the `.toc` file should sit directly inside `Interface/AddOns/ShadowedUnitFrames/`).
4. Restart the game client or reload your UI (`/reload`).

## Reporting issues

If you run into errors after a Classic/TBC client update, please open an issue with:

- The exact client build/version you're on.
- The full Lua error message and stack trace (a BugSack/BugGrabber capture is ideal).
- Steps to reproduce, if known.

Pull requests that fix compatibility breakage are welcome. Feature requests are likely out of scope for this fork — consider raising those upstream instead.
