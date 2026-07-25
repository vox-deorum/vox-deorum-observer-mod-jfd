# Dead code inventory (stage 2)

Stage 1 of the footprint reduction deleted **whole files only** — 63 files, 9.02 MB → 1.65 MB of
shipped payload. `TopPanel.lua` and `TopPanel.xml` were deliberately left byte-identical.

This document catalogues the dead code that remains *inside* surviving files, as a work list for
a later pass. Nothing here is urgent: none of it executes, and none of it is a correctness bug.

**Before deleting anything below, re-verify it against the current file.** Line numbers are from
the state at the end of stage 1 and will drift as soon as the first edit lands.

---

## 1. `Lua/UI/Overrides/TopPanel.lua` — ~1330 inert lines

Lines **~1385–2717** are a verbatim copy of the vanilla BNW `TopPanel.lua`, under a
`-- TopPanel.lua` banner comment. It is unreachable:

- `UpdateData()` and `DoInitTooltips()` are commented out at lines 2734–2735.
- The three `Events.SerialEvent*Dirty.Add(OnTopPanelDirty)` registrations are commented out at 2729–2731.
- Every control it drives (`TopPanelInfoStack`, `TopPanelInfoStackLeft`, `TopPanelInfoBar`) is `Hidden="1"`.

Contents: `UpdateData`, `OnTopPanelDirty`, and nine `*TipHandler` functions (`ScienceTipHandler`,
`GoldTipHandler`, `HappinessTipHandler`, `GoldenAgeTipHandler`, `CultureTipHandler`,
`TourismTipHandler`, `FaithTipHandler`, `ResourcesTipHandler`, `InternationalTradeRoutesTipHandler`).

> ### ⚠️ Do not blanket-delete this range
> Three small handlers sit **inside** it but are wired to **live, visible** controls at
> [TopPanel.lua:1763-1769](../Lua/UI/Overrides/TopPanel.lua#L1763-L1769):
> `OnGoldClicked`, `OnMilitaryClicked`, `OnTechClicked` — bound to `CapInfo`, `CitiesInfo`,
> `PopInfo`, `MilInfo`, `TreInfo`, `ResInfo`. Preserve them (or move them above the deleted
> region) or the top-panel stat clicks stop working.
>
> `OnScoreClicked` (1740) and `OnGovernmentClicked` (1754) are in the same neighbourhood but are
> **not** registered to any control — those two are safe to drop.

## 2. `Lua/UI/Overrides/TopPanel.xml` — 64 `Hidden="1"` elements

Candidates whose parents are never un-hidden by any surviving Lua:

- **Buttons that can never be shown:** `IGEButton`, `InfoAddictButton`, `OverlayMapsButton`,
  `PediaButton`. Deleting these subtrees would also free `IGEButton(HL).dds`,
  `InfoAddictButton(HL).dds`, `overlaymapbutton(hl).dds`, `PediaButton(HL).dds` — **but check
  `Lua/UI/MiniMap/MiniMapPanel.xml` and `Lua/JFD_AIObserver_Functions.xml` first**, both of which
  also reference the IGE and overlay-map textures.
- `PlayerScore` / `PlayerScoreLabel` / `PlayerScoreIcon` — the sole consumer of
  `JFD_GetScoreRank`; frees `aiobserversymbolrankedframe45.dds`.
- `DiploPanelLeft` (frees `diplomacypanelleft.dds`, 396 KB — the largest surviving texture),
  `TopLeftDecor` (`leftportraitdecor128real.dds`), `TopCentre` (`topcentreaiobserver.dds`).
- The commented-out `Stability` stack at lines **287–301**; it holds the only reference to
  `topleftframe2.dds`, which stage 1 already deleted as inert.
- Vanilla leftovers driven only by the dead region in §1: `TopPanelInfoStack`, `SciencePerTurn`,
  `GoldPerTurn`, `InternationalTradeRoutes`, `HappinessString`, `GoldenAgeString`,
  `CultureString`, `TourismString`, `FaithString`, `ResourceString`, `UnitSupplyString`.

Commented-out control IDs that can go with them: `CurrentTern2`, `CurrentTorn`, `LeftInfoStack`,
`RightInfoStack`, `HelpTextBox`, `IdeoInfo2`, `FolInfo`.

## 3. `Lua/Utilities/JFD_AIObserver_Utils.lua` — unreachable functions

Not called from anywhere in the surviving keep set:

| Function | Line | Note |
|---|---|---|
| `getStackTrace` | 16 | debug helper |
| `Game_IsCulDivActive` | 57 | |
| `Game_IsVMCActive` | 73 | |
| `Game.GetRandom` | 81 | |
| `JFD_AIObserver_PopulateLeaderFlavours` | 106 | runs at load; only feeds `GetFlavorValue` |
| `LuaTypes.Player.GetFlavorValue` | 130 | only consumer is `Player_GetFakeGovernment` |
| `LuaTypes.Player.GetDefaultName` | 150 | |
| `Player_GetFakeGovernment` | 229 | ~90 lines; sole user of the `ICON_JFD_LEGEND_GOV_*` glyphs |
| `Player_GetMajorityReligion` | 289 | |
| `Player_GetMainReligion` | 310 | |
| `JFD_GetScoreRank` | 336 | only consumer is the hidden `PlayerScore` control (§2) |
| `LuaTypes.Player.GetCityDescriptor` | 449 | |

**Still live and must be kept:** `Game.GetRound` (87 — used by `VD_FormatPopulation` for the
population stat in both the top panel and the civ list), `Player_GetIdeology` (162),
`Game_IsIGEActive` (61), `Game_IsInfoAddictActive` (65).

### Coupled cleanups

- **`Game_IsInfoAddictActive` is defined twice**, identically, at lines 65 and 69. Harmless, but
  the second definition should just be deleted.
- Removing `GetCityDescriptor` lets you also drop the load-time
  `DB.Query("SELECT * FROM JFD_CityDescriptors")` at line 444 — and only then
  `Core/JFDCityDescriptors_AIObserver.sql` plus the `CREATE TABLE JFD_CityDescriptors` block in
  `Core/JFDMaster_AIObserver.sql`. **Order matters:** that query runs at *include* time, so
  dropping the table while the query survives takes down `TopPanel`, `MiniMapPanel`, and
  `JFD_AIObserver_Functions` with it.
- Removing `GetFlavorValue` + `PopulateLeaderFlavours` lets you drop the
  `DB.Query("SELECT * FROM Leader_Flavors")` at line 101 (vanilla table, so no SQL file to remove).
- Removing `Player_GetFakeGovernment` removes the last `ICON_JFD_LEGEND_GOV_*` usage — but
  **`Art/Font Icons/JFDFontIcons_Players_OverlayMaps_22.dds` must still stay**, because
  `[ICON_LEGEND_ANARCHY]` is live at [TopPanel.lua:614](../Lua/UI/Overrides/TopPanel.lua#L614).

## 4. `Core/` leftovers

- **`Core/JFDColors_AIObserver.sql`** — 96 `COLOR_*` rows; only 12 are read by surviving code:
  `COLOR_JFD_OVERLAY_HAPPINESS`, `_UNHAPPINESS_3`, `_UNHAPPINESS_4`, `_GOLDEN_AGE`, `_DARK_AGE`,
  `_ANARCHY`, `_YIELD_GOLD`, `COLOR_RANK_GOLD/SILVER/BRONZE/COAL/IRON`. The rest is the overlay-map
  shading ramp. Trimming saves ~6 KB — low value, do it only while touching the file anyway.
- **`Core/JFDGameText_AIObserver.xml`** — 12 `*_TITLE_SHORT` keys are now orphaned; stage 1
  deleted `JFDPolicyBranches_AIObserver.sql`, which was the only thing that wrote
  `PolicyBranchTypes.TitleShort`.
- **`Core/JFDGameOptions_AIObserver.sql`** — `GAMEOPTION_JFD_AIOBSERVER_AUTORESOLVE_WC` is defined
  but never read; its consumer was removed before stage 1. The two `SUPPRESS_*` options are live.
- **`Core/Overlay Maps/JFDIconFonts_OverlayMaps.sql`** — kept, and load-bearing, but only two of
  its ~35 mappings matter: `ICON_LEGEND_ANARCHY`, plus the `ICON_LEGEND_ERA_*` handles that
  `Core/JFDIconFonts_AIObserver.sql:31-40` points at this texture. It must stay **first** in
  `<OnModActivated>` (commit 7951013). Consider folding the two live rows into
  `JFDIconFonts_AIObserver.sql` and retiring the file and its 116 KB sheet entirely — that would
  require re-indexing `ICON_LEGEND_ANARCHY` onto the AIObserver glyph sheet.

## 5. Inert event wiring

`LuaEvents.JFD_UI_ShowOverlayMapsOverview()` is still fired from
[TopPanel.lua:1233](../Lua/UI/Overrides/TopPanel.lua#L1233) and
[JFD_AIObserver_Functions.lua:49](../Lua/JFD_AIObserver_Functions.lua#L49). Its only listener
(`Lua/JFD_UI_OverlayMapsOverview.lua`) was deleted in stage 1. Both trigger buttons are
`Hidden="1"` and nothing un-hides them, so this is inert rather than broken — but the two firing
sites and their `OnOverlayMapsButton` handlers should go with §2.

The working overlay path is untouched: `MiniMapPanel.lua:84` →
`LuaEvents.JFD_UI_ShowBigMiniMapOverview()` → `JFD_UI_BigMiniMapOverview.lua:141`.

---

## 6. Pre-existing gaps (not caused by the cleanup)

Worth fixing, but they predate stage 1 — do not mistake them for regressions:

- `[ICON_TROPHY_GOLD]`, `[ICON_TROPHY_SILVER]`, `[ICON_TROPHY_BRONZE]`
  ([TopPanel.lua:456-460](../Lua/UI/Overrides/TopPanel.lua#L456-L460)) and `[ICON_DARK_AGE]`
  (line 608) are defined in neither this mod, CP, nor VP — they come from JFD's Rise to Power /
  Sovereignty. They render as missing glyphs. Note `ICON_TROPHY_IRON` and `ICON_TROPHY_GRAPHITE`
  *are* defined here, so only the top-three ranks are affected.
- `TXT_KEY_JFD_HIDE_RESOURCES` / `TXT_KEY_JFD_UNHIDE_RESOURCES` (`TopPanel.xml:578,580`) are
  defined nowhere and render as raw key text. Two rows in
  `Core/JFDGameText_Interface_AIObserver.xml` would fix it.
- `JFD_AIObserver_Utils.lua:8-9` includes `JFDLC_Utils_ActiveMods.lua` and `PlotIterators.lua`,
  neither of which ships with this mod. `PlotIterators.lua` is a base-game file; the other comes
  from JFD's Lua Companion. If it is absent the utils file fails to load and takes `TopPanel`
  with it.
- `Art/Images/bottomright128x224_2.dds` is kept only defensively: `MiniMapPanel.xml:16`
  references it via an `assets\UI\Art\WorldView\...` path, which should resolve to the base-game
  copy. If in-game testing confirms the minimap corner renders correctly without it, it can be
  deleted (114 KB).
- All 27 surviving textures are uncompressed A8R8G8B8 with no mipmaps. Converting to DXT5/BC3
  would cut ~1.1 MB to ~300 KB, at the cost of possible alpha/gradient artifacts on the panel
  backings. Deferred by user decision in stage 1.
