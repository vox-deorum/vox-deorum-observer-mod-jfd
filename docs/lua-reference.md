# Lua reference

## Shared utilities

### `JFD_AIObserver_Utils.lua`

| Function | Purpose |
|---|---|
| `Game_IsIGEActive()` | Tests whether In-Game Editor is active. |
| `Game.GetRound(number, decimals)` | Rounds a number; used by population formatting. |
| `Player_GetIdeology(player, notSpirit)` | Returns the player's ideology, including the optional JFD Spirit branch. |

### `VD_Observer_Utils.lua`

| Function | Purpose |
|---|---|
| `VD_Log(...)` | Prefixes observer diagnostics with `[VD]` in the Lua log. |
| `VD_ResolveCityPlot(...)`, `VD_FindNearestCity(...)` | Resolve event positions to plots/cities. |
| `VD_BuildEventInfo(...)` | Builds camera/animation event metadata. |
| `VD_GetSessionResults()` | Returns World Congress results cached from `ResolutionResult`. |
| `VD_BuildCombatDescription(...)` | Formats a combat summary. |
| `VD_GetGrandStrategy(player)` | Returns icon, short label, and description for the active grand strategy. |
| `VD_FormatPopulation(player)` | Formats empire population for the HUD. |
| `VD_GetGoldDisplay(player)` | Formats income, treasury, and tooltip values. |
| `VD_GetThinkingTitle(label)` | Builds an LLM processing title. |
| `VD_GetTurnProcessingDisplayMode(playerID)` | Selects known/unmet/minor/barbarian display mode. |
| `VD_ShowTurnProcessing(...)` | Emits the turn-processing UI event. |
| `VD_SetStatControl(...)`, `VD_ResizeEntryBox(...)` | Shared top-panel control helpers. |

## Observer controllers

### `TopPanel.lua`

Consumes:

- `LuaEvents.VoxDeorumPlayerInfo(playerID, aiLabel)`
- `LuaEvents.VoxDeorumAction(playerID, turn, actionType, summary, rationale)`
- AI processing, combat, city, production, goody-hut, and camera events

Emits:

- `VD_TopPanelAutoSwitchedPlayer`
- `VD_AnimationStarted`
- `VD_ShowActionDialog`
- `VD_ShowTurnProcessing` through the shared helper

The file also owns the player pulldown, the world-civs list, viewed-player camera movement, and the
six live stat click targets.

### `TurnProcessing.lua`

Listens for `VD_ShowTurnProcessing` and renders the correct title/icon for known, unmet, minor, and
barbarian turns. It hides the popup when the active or remote human turn starts.

### `JFD_UI_BigMiniMapOverview.lua`

Copies the engine minimap texture into a larger popup. It can be opened by the minimap button, the
Additional Information dropdown, or `JFD_UI_ShowBigMiniMapOverview`.

### `JFD_AIObserver_Functions.lua`

Conditionally registers two local handlers:

- `Events.NotificationAdded` clears intrusive goody-hut and archaeology notifications.
- `Events.SerialEventGameMessagePopup` dequeues the configured reward/era/wonder popups.
