# VD LLM Observer Integration — Implementation Plan

## Context

The AI Observer Interface mod displays AI-only Civ5 games. The vox-deorum backend runs LLM players and fires LuaEvents (`VoxDeorumPlayerInfo`, `VoxDeorumAction`) per the observer-api protocol. We are adding 5 new features to surface LLM decisions in the existing UI. Each stage is committed and tested in-game before the next begins.

---

## Critical Files

| File | Role |
|------|------|
| `Lua/UI/Overrides/TopPanel.lua` | Main player panel controller — Stages 1–4 |
| `Lua/UI/Overrides/TopPanel.xml` | Top-left panel layout — Stage 4 XML changes |
| `Lua/JFD_AIObserver_Functions.lua` | Entry point / event broker |
| `JFD's Utilities - AI Observer Interface (v 11).modinfo` | Must register any new InGameUIAddin files |

Existing utilities to reuse:
- `JFD_Log()` from `Lua/Utilities/JFD_AIObserver_Utils.lua` — debug logging
- `LuaTypes.Player.GetDefaultName()` — leader name fallback
- `JFD_GetScoreRank()` — player ranking
- Civ5 built-in `InstanceManager` — for repeating UI rows in Stage 5 dialog

**Naming convention:** All new symbols use `VD_` prefix (e.g., `VD_Players`, `VD_Actions`, `VD_ShowActionDialog`).

---

## Stage 1 — LuaEvent Handling & State Storage

**Files:** `Lua/UI/Overrides/TopPanel.lua`

**Goal:** Wire up VoxDeorum LuaEvents and accumulate per-player state in local tables so later stages can read it.

**State tables** added near the top of TopPanel.lua:

- `VD_Players[playerID]` — keyed by playerID, stores the `aiLabel` string from `VoxDeorumPlayerInfo`
- `VD_Actions[playerID]` — keyed by playerID, stores `{ turn, list }` where `list` is an array of `{ actionType, summary, rationale }` records from `VoxDeorumAction`

**Turn tracking:** When a `VoxDeorumAction` arrives with a `turn` value different from the one stored for that player, clear the list before inserting. This ensures the tables always reflect only the current turn's actions.

**Panel refresh:** After updating state, each handler checks if the incoming `playerID` matches `g_iPlayerForView`. If so, it calls `UpdateNewData` immediately, so the panel updates live as events stream in during a turn.

**No visual change in this stage.** Verify by temporarily calling `JFD_Log` inside each handler to confirm events arrive with the expected parameters.

---

## Stage 2 — Show aiLabel Instead of Leader Name

**Files:** `Lua/UI/Overrides/TopPanel.lua`

**Goal:** Replace the Civ5 leader name in `PlayerLeaderNameText` with the LLM identifier for every major player.

**Logic change** in `UpdateNewData`, at the point where `PlayerLeaderNameText` is currently set to the leader's real name:

- If the player is a minor civ — keep existing behavior (show leader name)
- If `VD_Players[playerID]` exists — display `aiLabel` (e.g., `"deepseek-r1 / simple-strategist"`)
- If no VD data has arrived yet — display `"Unknown"`

No XML changes needed; `PlayerLeaderNameText` already exists in the layout at `TopPanel.xml:269`.

**Verification:** All major civs show "Unknown" at game start, then switch to their aiLabel once vox-deorum fires the events.

---

## Stage 3 — Auto-Switch Panel to the Active AI Player

**Files:** `Lua/UI/Overrides/TopPanel.lua`

**Goal:** When any major AI player begins their turn, automatically switch the top-left panel to display that player without any manual interaction from the observer.

**Design:** Register a new handler for `Events.AIProcessingStartedForPlayer`. When it fires for a non-minor, non-barbarian player:

1. Set `g_bPlayerForViewLookup = false` — this flag already exists and suppresses the camera jump that `OnCivPlayerSelected` normally triggers
2. Call `OnCivPlayerSelected(playerID)` — the existing function that sets `g_iPlayerForView`, refreshes the panel, and repopulates the player pulldown
3. Restore `g_bPlayerForViewLookup = true`

This reuses all existing player-switch infrastructure without duplication.

**Verification:** The top-left panel automatically cycles through each major civ's turn in sequence each round, without moving the camera.

---

## Stage 4 — Extended LLM Info in the Top-Left Panel

**Files:** `Lua/UI/Overrides/TopPanel.lua`, `Lua/UI/Overrides/TopPanel.xml`

### 4a — Stat Icon Visual Redesign (XML)

**Current:** Each of the 7 stats (Capital, Cities, Population, Military, Research, Gold, Happiness) is wrapped in a small Image using `topleftframe22.dds`, giving each its own bordered box.

**New:** Remove the `topleftframe22.dds` texture from each `XxxInfoFrame` image (set to transparent/empty). The stats continue to flow horizontally in `InfoStack`. Between adjacent stats, unhide the existing `Divider.dds` elements (already present at `5×16` px between each stat in the XML but currently hidden) to act as thin vertical separators. Result: a cleaner row with subtle vertical rules between stats, no individual boxes.

### 4b — Panel Sizing (XML)

Increase `<Container ID="Tab">` height from `150` to **`225`** to accommodate the new rows below the stat bar. The existing background image (`topleftaiobserver3.dds`) is anchored at top-left and will continue to fill correctly. New elements are hidden by default when no VD data is present, so the panel looks the same as before for non-LLM sessions.

### 4c — New UI Elements Below the Stat Bar (XML)

Two new elements are added inside `PlayerEntryBox`, positioned below `TopLeft2`:

**Row 1 — Action Summary Line**

A text label spanning the panel width, showing all actions taken last turn as a compact, comma-separated list:

```
Changes: Strategy, Flavor, Relationship (China), Next Policy
```

- Prefixed with `"Changes: "` whenever any action exists
- Each action type rendered as a friendly name (see table in §4d)
- For `relationship` actions, the target civ name (extracted from the `summary` text) is appended in parentheses
- Text truncates with ellipsis if wider than ~460 px
- Hidden when no VD data exists for the current player

A small `"Details"` button sits at the right end of this row. Clicking it fires `LuaEvents.VD_ShowActionDialog(g_iPlayerForView)` to open the Stage 5 dialog.

**Row 2 — Rationale Paragraph**

A multi-line wrapped text block showing the rationale for the first strategy, flavor, or status-quo action found in the current turn's list.

- A semi-transparent dark background box (`Color="0,0,0,160"` or similar) sits behind the text to ensure legibility against the panel's decorative background image
- Fixed height accommodating ~3–4 wrapped lines; text beyond that is clipped (full text visible in Stage 5 dialog)
- Hidden when no applicable rationale exists for this turn

### 4d — Lua Logic (TopPanel.lua)

A new helper `VD_UpdatePanelExtras(playerID)` is called at the end of `UpdateNewData`'s major-player branch. It:

1. Checks that the player is major and has VD action data; hides both rows otherwise
2. Builds the summary string by iterating `VD_Actions[playerID].list` and mapping each `actionType` to its friendly name, appending target context where available
3. Finds the first non-empty `rationale` among strategy/flavor/status-quo actions for Row 2
4. Shows/hides and populates each element accordingly

**Action type → friendly name mapping:**

| actionType | Friendly Name |
|---|---|
| `strategy` | Strategy |
| `research` | Research |
| `policy` | Policy |
| `relationship` | Relationship |
| `persona` | Persona |
| `flavors` | Flavor |
| `unset-flavors` | Flavor Reset |
| `status-quo` | Status Quo |

The Details button callback is registered once (at load time) to fire `LuaEvents.VD_ShowActionDialog`.

**Verification:** With vox-deorum running, the summary row and rationale block appear and update live as each player's turn events arrive. Hidden cleanly when no data exists.

---

## Stage 5 — Action Detail Dialog

**Files:** new `Lua/VD_ActionDialog.lua` + `Lua/VD_ActionDialog.xml`, plus an entry in `.modinfo`

### Design Philosophy

A focused, scannable popup showing one LLM player's full action list for their most recent turn. A dropdown at the top switches between any player that has VD data. Each action is a distinct row with a separator line. Rationale is shown inline below its parent action, indented, and only when non-empty.

### Visual Layout

```
┌─────────────────────────────────────────────────────────┐
│  LLM Actions                              Turn 47       │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Rome / deepseek-r1 / simple-strategist    [▼]  │   │
│  └─────────────────────────────────────────────────┘   │
├─────────────────────────────────────────────────────────┤
│  ╔═══════════════════════════════════════════════════╗  │
│  ║  ────────────────────────────────────────────── ║  │
│  ║  Strategy     Shifted to defensive posture       ║  │
│  ║               "The empire borders three aggres-  ║  │
│  ║                sive civs. A defensive stance      ║  │
│  ║                will reduce losses while…"         ║  │
│  ║  ────────────────────────────────────────────── ║  │
│  ║  Research     Now researching Iron Working        ║  │
│  ║               "Iron Working unlocks Swordsmen,    ║  │
│  ║                a key unit for early expansion."   ║  │
│  ║  ────────────────────────────────────────────── ║  │
│  ║  Relations    Improved relations with Egypt       ║  │
│  ║  ────────────────────────────────────────────── ║  │
│  ║  Status Quo   Maintaining current direction       ║  │
│  ║               "Expansion is proceeding well. No  ║  │
│  ║                strategic changes warranted."      ║  │
│  ║  ────────────────────────────────────────────── ║  │
│  ╚═══════════════════════════════════════════════════╝  │
│                                         [ Close ]       │
└─────────────────────────────────────────────────────────┘
```

**Dimensions:** ~620 × 560, centered on screen
**Title row:** "LLM Actions" on the left, "Turn N" on the right, same line
**Player pulldown:** full-width dropdown below title, shows `CivName / modelLabel / strategistLabel`; lists all players present in `VD_Players`
**Action list:** inside a `ScrollPanel` (the double-border region above); each action row has a thin full-width top separator line
**Action row layout:** action type label (left, ~90 px fixed column), summary text (right, wrapping to full remaining width)
**Rationale sub-row:** same indentation as summary, slightly smaller font, shown only when `rationale` is non-empty
**Close button:** bottom-right corner, outside the scroll panel

### Architecture

**State:** `VD_ActionDialog.lua` maintains its own local `VD_Players` and `VD_Actions` tables, with handlers registered directly on `LuaEvents.VoxDeorumPlayerInfo` and `LuaEvents.VoxDeorumAction` using the same turn-tracking logic as Stage 1. This avoids any cross-context table passing.

**Open/close:** The dialog starts hidden. It registers on `LuaEvents.VD_ShowActionDialog(playerID)` to show and pre-select the given player. The close button hides it.

**Action rows:** Built dynamically using `InstanceManager` with an `ActionRowInstance` template in the XML. Each instance contains: a separator line image, an action-type label, a summary label, and a rationale label. The rationale label is always shown when `rationale` is non-empty; it is hidden when `rationale` is absent or empty. The instance manager is reset and rebuilt on every `VD_RefreshDialog` call.

**Scroll:** The action list sits inside a `ScrollPanel` so long lists with multiple rationale blocks remain fully accessible.

### modinfo Registration

A new `InGameUIAddin` entry is added in `JFD's Utilities - AI Observer Interface (v 11).modinfo` pointing to `Lua/VD_ActionDialog.lua`.

**Verification:** Clicking "Details" in the top-left panel opens the dialog pre-selected on the currently viewed player. Switching the dropdown repopulates the list for that player. Rationale sub-rows appear only when content is present. Scroll works for long lists. Close button hides the dialog.
