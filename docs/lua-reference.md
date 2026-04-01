# Lua Reference

Function-level reference for all Lua files in the mod. Files are listed in dependency order (utilities first, then UI controllers, then the entry point).

---

## Utilities

### `Lua/Utilities/JFD_AIObserver_Utils.lua`

Shared helper library. Imported by all other Lua files.

#### Debug

| Function | Description |
|----------|-------------|
| `JFD_Log(msg)` | Writes a debug message to the Lua log with mod prefix. |
| `JFD_StackTrace()` | Returns a formatted stack trace string for error reporting. |

#### Mod Detection

| Function | Description |
|----------|-------------|
| `JFD_IsModActive(modID)` | Returns `true` if the given mod ID is loaded and active. |
| `JFD_IsIGEActive()` | Checks for In-Game Editor. |
| `JFD_IsInfoAddictActive()` | Checks for Info Addict. |
| `JFD_IsCulDivActive()` | Checks for Cultural Diversity. |
| `JFD_IsSovereigntyActive()` | Checks for JFD's Sovereignty mod. |
| `JFD_IsVMCActive()` | Checks for VMC (Vox Populi More Civs). |
| `JFD_IsJFDLLActive()` | Checks for JFD's DLL mod. |

#### Math Utilities

| Function | Description |
|----------|-------------|
| `JFD_Round(n, decimals)` | Rounds `n` to `decimals` places. |
| `JFD_Random(min, max)` | Returns a random integer in `[min, max]`. |

#### Player Utilities

| Function | Description |
|----------|-------------|
| `JFD_GetLeaderFlavour(leaderType, flavourType)` | Queries `Leader_Flavors` table; returns the leader's value for the given flavor. |
| `JFD_GetDefaultLeaderName(playerID)` | Returns the default leader name string for a player. |
| `JFD_GetPlayerIdeology(playerID)` | Returns the player's current ideology type string. |
| `JFD_GetPlayerGovernment(playerID)` | Returns the player's current government type (requires Sovereignty). |

#### City Utilities

| Function | Description |
|----------|-------------|
| `JFD_GetCityDescriptor(city)` | Returns a formatted string describing a city's status: resistance, puppet, colony. |
| `JFD_GetCityClass(city)` | Classifies a city by population (hamlet, town, city, metropolis, etc.). |

#### Religion Utilities

| Function | Description |
|----------|-------------|
| `JFD_GetCityReligionMajority(city)` | Returns the religion type with the most followers in a city, or `nil`. |
| `JFD_GetPlayerMainReligion(playerID)` | Returns the religion type founded or majority-held by a player. |

#### Score / Ranking

| Function | Description |
|----------|-------------|
| `JFD_GetPlayerRank(playerID)` | Returns the player's rank (1 = highest score) among all major civs. |
| `JFD_GetRankColour(rank, totalPlayers)` | Returns a color tier string: `"Gold"`, `"Silver"`, `"Bronze"`, `"Coal"`, `"Iron"`. |

---

### `Lua/Utilities/JFD_AIObserver_Minimap_Utils.lua`

Helpers specific to minimap rendering. Imported by the minimap UI files.

| Function | Description |
|----------|-------------|
| `JFD_GetMiniMapLegend(legendType)` | Returns legend configuration data for the given legend type key. |
| `JFD_GetTerrainColour(terrainType)` | Returns RGB color table `{r, g, b}` for a terrain type. |
| `JFD_GetFeatureColour(featureType)` | Returns RGB color table for a map feature (ice, forest, etc.). |
| `JFD_GetMaxMajorPlayers()` | Returns the maximum number of major civ player slots (cached). |
| `JFD_GetMaxMinorPlayers()` | Returns the maximum number of city-state player slots (cached). |
| `JFD_GetGameSpeed()` | Returns the current game speed type string. |
| `JFD_GetHandicap()` | Returns the current game handicap type string. |

Active mod detection mirrors `JFD_AIObserver_Utils.lua` — these functions are available here for modules that only include this file.

---

### `Lua/Utilities/JFD_OverlayMaps_Utils.lua`

Helpers for the overlay maps system. See also [overlay-maps.md](overlay-maps.md).

| Function | Description |
|----------|-------------|
| `JFD_GetOverlayMapClasses()` | Returns all rows from `JFD_OverlayMapClasses`. |
| `JFD_GetOverlayMapFilters(classType)` | Returns filter rows for a given class. |
| `JFD_AssignOverlayColour(playerID, overlayType)` | Returns the color to use for a player under a given overlay. |

---

## UI Controllers

### `Lua/JFD_UI_BigMiniMapOverview.lua`

Full-screen minimap popup. Entry point: `JFD_UI_BigMiniMapOverview.xml` (loaded as `InGameUIAddin`).

#### Initialization

| Function | Description |
|----------|-------------|
| `Initialize()` | Called on UI load. Wires all controls, loads color tables, sets initial state. |
| `AssignPlayerColours()` | Queries game civilization data to build per-player color tables. |
| `AssignReligionColours()` | Queries religion data to assign a distinct color to each founded religion. |

#### Refresh / Rendering

| Function | Description |
|----------|-------------|
| `RefreshMiniMapOverview()` | Master refresh: calls all sub-refresh functions to fully redraw the popup. |
| `RefreshPlayers()` | Populates the Civs and City States legend sections. |
| `RefreshLegends()` | Updates all collapsible legend headers and their children. |
| `RefreshMiniMapOverlay()` | Manages the overlay pulldown menu population. |
| `ShadeCities(overlayMode)` | Colors each map tile based on city ownership or religion majority. |

#### Controls (event handlers)

| Control / Event | Handler | Description |
|----------------|---------|-------------|
| Show All Revealed checkbox | — | Toggles whether unrevealed tiles are shown. |
| Show Barbarians checkbox | — | Toggles barbarian unit/city display. |
| Show Cities checkbox | — | Toggles city icon visibility. |
| Show Units checkbox | — | Toggles unit icon visibility. |
| Show Water Tiles checkbox | — | Toggles water tile coloring. |
| "Show As" dropdown | — | Sets the player perspective for fog-of-war rendering. |
| Overlay pulldown | — | Switches the active map overlay mode. |
| Legend section headers | — | Collapse/expand legend subsections. |

---

### `Lua/JFD_UI_MiniMapOverview.lua`

Lightweight minimap popup, accessible from the Additional Information dropdown.

| Function | Description |
|----------|-------------|
| `JFD_UI_ShowMiniMapOverview()` | Toggles popup visibility. |
| `ShowHideHandler(isHiding)` | Manages the UI timer semaphore when popup is shown or hidden. |
| `RefreshMiniMapOverview()` | Refreshes minimap display contents. |

---

### `Lua/JFD_UI_OverlayMapsOverview.lua`

Overlay maps popup. Provides multi-level class/filter selection and a colored legend.

| Function | Description |
|----------|-------------|
| `Initialize()` | Sets up controls and populates class dropdown. |
| `RefreshOverlayMaps()` | Redraws the overlay map display for the selected class and filter. |
| `RefreshLegends()` | Rebuilds the legend (Civs, City States, Barbarians, Religions, Options sections). |
| `OnClassChanged(classType)` | Called when the user changes the overlay class dropdown. |
| `OnFilterChanged(filterType)` | Called when the user changes the filter dropdown within a class. |

---

## Entry Point

### `Lua/JFD_AIObserver_Functions.lua`

The main mod entry point. Loaded via `JFD_AIObserver_Functions.xml` as an `InGameUIAddin`.

#### UI Setup (fires on `Events.LoadScreenClose`)

| Function | Description |
|----------|-------------|
| `JFD_AIObserver_ChangeMapOptionsParent()` | Moves the IGE button into the map options button group. |
| `OnOverlayMapsButton()` | Opens the Overlay Maps Overview popup. |
| `OnIGEButton()` | Shows or hides the In-Game Editor panel. |

#### Event Handlers

| Handler | Event | Description |
|---------|-------|-------------|
| `JFD_AIObserver_NotificationAdded(playerID, notifType, ...)` | `Events.NotificationAdded` | Suppresses ancient ruins and archaeology notifications when option is enabled. |
| `JFD_AIObserver_SerialEventGameMessagePopup(popupInfo)` | `Events.SerialEventGameMessagePopup` | Auto-dismisses golden age, great person, new era, and other popups when option is enabled. |

#### Game Options Checked

| Option Key | Effect |
|-----------|--------|
| `GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS` | Enables notification suppression. |
| `GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS` | Enables popup suppression. |

---

## UI Override Files

These files replace base-game Lua controllers. They integrate observer functionality into standard UI panels. Changes here must maintain compatibility with base-game behavior.

| File | Overrides | Notes |
|------|-----------|-------|
| `Lua/UI/MiniMap/MiniMapPanel.lua` | Base minimap panel | Adds observer button hooks |
| `Lua/UI/Overrides/TopPanel.lua` | Top HUD panel | Adds overlay map and observer buttons |
| `Lua/UI/Overrides/TopPanel_Back.lua` | Top panel background | Cosmetic layer |
| `Lua/UI/Overrides/DiploCorner.lua` | Diplomacy corner | Integrates with JFD's Rise to Power diplo corner |
| `Lua/UI/Overrides/CityBannerManager.lua` | City banners on map | Custom banner display |
| `Lua/UI/Overrides/NewTurn.lua` | New turn handler | Observer-specific new turn logic |
| `Lua/UI/Overrides/InfoCorner.lua` | Info corner element | Custom info display |
| `Lua/UI/Overrides/TurnProcessing.lua` | Turn processing | Observer turn event handling |
