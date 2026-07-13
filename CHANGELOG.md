# Changelog — Anniversary Maintenance Fork

This is a community-maintained fork of Shadowed Unit Frames, updated to work on
WoW Classic Anniversary (2.5.6 / build 68575). Original addon by Shadowed.

## 4.4.0-classic

### Fixed
- **Aura display crash on 2.5.6.** The global `UnitAura` function was removed in
  2.5.6. All aura lookups now go through a shared compatibility wrapper built on
  `C_UnitAuras.GetAuraDataByIndex` + `AuraUtil.UnpackAuraData` (identical return
  order), with a fallback to native `UnitAura` on older clients. Covers the aura
  frames, `UnitAuraBySpell`, and the aura-indicators module.
- **Debuff type colors.** The global `DebuffTypeColor` table was also removed in
  2.5.6; it is now rebuilt from the engine's `DEBUFF_TYPE_*_COLOR` constants with
  fixed-RGB fallbacks.
- **ADDON_ACTION_BLOCKED on combat.** `RegisterForClicks` is protected; calling it
  while a unit frame is created mid-combat caused a block error. It is now deferred
  during combat and flushed on `PLAYER_REGEN_ENABLED`.

### Changed
- TOC Interface bumped to include 20506 (2.5.6).
- Version string materialized (dropped the `@project-version@` packager placeholder).
