# Architecture

## Runtime components

The mod is a Civ5 observer HUD adapted for vox-deorum. Its shipped runtime has four parts:

| Component | Files | Responsibility |
|---|---|---|
| Observer top panel | `Lua/UI/Overrides/TopPanel.*` | Viewed-player stats, player selector, world-civs list, LLM rationale, event playback, camera focus, and automatic player switching |
| Turn indicator | `Lua/UI/Overrides/TurnProcessing.*` | Displays which known, unmet, minor, or barbarian player is processing |
| League overview | `Lua/UI/Overrides/LeagueOverview.lua` | Vox Populi World Congress screen plus session-result reporting |
| Minimap | `Lua/UI/MiniMap/MiniMapPanel.*`, `Lua/JFD_UI_BigMiniMapOverview.*` | Standard map options and a full-screen enlargement of the engine minimap |

`DiploCorner.*` remains as a multiplayer-chat-only base-game override. `NewTurn.*` is intentionally
empty so it suppresses the vanilla new-turn banner without registering an inert turn handler.

## Data flow

```text
vox-deorum LuaEvents
  ├─ VoxDeorumPlayerInfo
  └─ VoxDeorumAction
          │
          ▼
TopPanel per-player cache ──► top-panel rationale + world-civs rows
          │
AI/combat/city events
          ├─► viewed-player switching
          ├─► camera focus / animation events
          └─► event-message playback

MinimapTextureBroadcastEvent ──► minimap panel + full-screen minimap
ResolutionResult             ──► LeagueOverview session results
```

## Load sequence

1. `<OnModActivated>` loads the observer icon-font registration, the small color table, localized
   text, and the two VP API extension flags.
2. The `JFD_UI_BigMiniMapOverview.lua` entry point creates an independent UI context.
3. Files marked `import="1"` replace the corresponding VP/EUI or base-game UI files.
4. `TopPanel.lua` includes `JFD_AIObserver_Utils.lua` and `VD_Observer_Utils.lua`; the custom
   minimap includes only the JFD helper needed for IGE detection.

## Database footprint

The runtime database additions are deliberately small:

- six text colors used by the live HUD;
- seven observer icon mappings;
- English text for the minimap title, civ-list title, abbreviated months, and turn counter;

The former overlay-map schema and font registration, city descriptors, leader-flavor cache, score
ranking, and their supporting text/icon/color rows are not shipped.
