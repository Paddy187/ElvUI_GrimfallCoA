# Changelog

All notable changes to this project will be documented in this file.

## [6.19] - 2026-10-18
### Added
- Castbar text X/Y offsets for the spell name and the cast time, separately, on unit frames (Castbar > Text) and nameplates (Cast Bar > Text).

## [6.18] - 2026-10-18
### Fixed
- Nameplate preview: the castbar now stays visible with a looping test cast (spell name, cast time and icon) whenever the castbar is enabled for that unit type, and follows option changes. It used to disappear right after the preview was opened.

## [6.17] - 2026-10-18
### Changed
- Frame Shadows: player buffs / debuffs (next to the minimap) are shadowed by default, and new aura icons get their shadow immediately.

## [6.16] - 2026-10-18
### Changed
- The Player "Power Stack" (CoA resource stack) is now disabled by default; the normal Player Power bar is used instead.

## [6.15] - 2026-10-18
### Fixed
- Nameplates: the name text now follows its position setting (LEFT / CENTER / RIGHT). It was always left-aligned inside a box as wide as the health bar, so a "CENTER" name sat left of the middle.

## [6.14] - 2026-10-18
### Compatibility: ElvUI_CoAResources
- Frame shadows cache their style, so ElvUI_CoAResources (which refreshes its pips every 0.2 s) no longer rebuilds up to 384 backdrops per refresh.
- Grimfall's own Player resource stack is now called "Power Stack" in the options and on its mover, so it no longer clashes with the addon's "CoA Resources" section.

## [6.13] - 2026-10-18
### Fixed / Added
- **CoA Resource Stack options** (UnitFrames > Player > CoA Resources): the Mana/Energy/... bars shown under the Player frame by default are the CoA stack, which replaces the Player Power/Energy/Rage/Mana/Runic bars. It now has full settings: per-resource Auto/Show/Hide, height, spacing, width, above/below, X/Y offset, detach with own mover, ElvUI border, text format/position/offset/font, texture, Base -> Gradient colors.
- The replaced Player bar option groups are greyed out with an explanation while the stack is enabled.
- Player frame no longer reserves Health space for Energy/Rage/Mana/Runic bars that are hidden for non-Hero characters; a missing bar offset counts as 0.

## [6.12] - 2026-10-18 - Arden feature port
### Added (ported from the Arden build, adapted to Grimfall)
- **Frame Shadows** (Skins > Shadows): configurable outer shadow (color/size) for action bars, unit frames, group frames (per unit), cast bars, unit frame aura icons, player buffs/debuffs, tooltips, data bars, minimap, chat/top/bottom panels, bags, loot frame/rolls, threat bar and nameplates (health, cast bar, cast icon, auras). Grimfall's CoA resource stack and the Energy/Rage/Mana/Runic bars have their own switches.
- **Information Panel**: "Top" position, "Outside Portrait", own texture and color.
- **Portraits**: "CoA Class" style, detach from frame (own mover + shadow), auto width.
- **Castbar**: per-unit texture, font, size, outline and text color; "Icon Inside Portrait"; InfoPanel docking respects the panel width.
- **Gradients (Base -> Gradient)**: health (class / CoA class / reaction / special), health-by-threshold coloring, power, cast bars (incl. class colors and interrupted), aura bars, class resources (runes / combo points), Energy/Rage/Mana/Runic bars, CoA resource stack, data bars (XP / pet XP / reputation), threat bar, loot rolls, tooltip faction health bar.
- **Textures**: per-element textures for Power, Castbar, InfoPanel, Classbar, extra resource bars, CoA stack, data bars, threat bar, loot roll and tooltip health bar.
- **Threat bar**: detach with own mover, size, font, text color/offset, custom colors, preview.
- **Combat / Rest icon**: preview toggle, "Material" textures. **RL/ML icons**: preview, size and offsets.
- **Misc**: movable Blizzard windows, World Map Fog of War reveal, Minimap Button Frame, square minimap mask fix, top/bottom panel texture/opacity/height/offset, objective tracker width/font/line spacing, new fonts (AvantGarde LT, Gotham XNarrow Ultra) and "CoA Clean" statusbar.
### Fixed
- Energy/Rage color callbacks no longer receive the unit string instead of the bar when called by oUF.

## [6.11] - 2026-01-31
### Fixed
- **Version Check Popup**: Disabled the "ElvUI was updated while the game is still running" popup by removing the `ELVUI_VERSIONCHK` addon message logic. This prevents false positives when the repository is not auto-updated.

## [6.10] - 2026-01-30
### Fixed
- **Critical Freeze Fix**: Resolved a client freeze issue occurring during `Reload UI`.
  - **Refactor**: Completely removed recursive `E:Delay` polling loops in `Ebonhold.lua`.
  - **Event-Driven Initialization**: Switched to `AceEvent-3.0` `PLAYER_ENTERING_WORLD` event for safe initialization of the Project Ebonhold skin module.
  - **Recursion Guard**: Implemented a "fight detection" mechanism in the `SetScale` hook. It now tracks call frequency within the same frame (`GetTime()`) and aborts if it detects a tug-of-war (recursion depth > 20) to prevent synchronous freezes.
- **Module Fix (ElvUI_SwingBar)**: Resolved a separate synchronous infinite loop in the optional SwingBar module.
  - **Recursion Guard**: Applied a recursion guard to the `Update_PlayerFrame` hook in `ElvUI_SwingBar.lua`. The hook was triggering layout updates that recursively called itself, causing an instant freeze. This guard limits execution to 20 calls per frame.

