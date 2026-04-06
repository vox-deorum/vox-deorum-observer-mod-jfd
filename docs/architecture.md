# Architecture

## Overview

The AI Observer Interface is a Civ5 mod that enhances the spectator experience for AI-only or CBR (Community Battle Royale) games. It adds rich visualization tools (minimap overlays, overlay maps) and reduces UI noise (popup suppression) so observers can passively watch AI behavior without constant interruption.

---

## Directory Structure

```
(3b) AI Observer Interface/
├── *.modinfo               # Mod metadata: ID, version, file list, DB actions, entry points
├── CreditsInfo.txt         # Author credits
│
├── Art/
│   ├── Font Icons/         # DDS + GGXML icon font sheets (22px)
│   │   ├── JFDFontIcons_AIObserver_22.*      # Observer UI icons
│   │   └── JFDFontIcons_Players_OverlayMaps_22.*  # Overlay map player icons
│   ├── Images/             # UI element textures (DDS): buttons, frames, borders, decorations
│   └── JFDFontIcons_AIObserver_SovGovs_22.*  # Sovereign government icons
│
├── Core/
│   ├── JFDMaster_AIObserver.sql        # Master table definitions
│   ├── JFDArtDefines_AIObserver.sql    # Art definition registrations
│   ├── JFDCityDescriptors_AIObserver.sql  # City descriptor entries
│   ├── JFDColors_AIObserver.sql        # Color palette definitions
│   ├── JFDGameOptions_AIObserver.sql   # Game option rows (suppress popups/notifs)
│   ├── JFDGameText_AIObserver.xml      # Localized strings (core)
│   ├── JFDGameText_Interface_AIObserver.xml  # Localized strings (UI)
│   ├── JFDIconFonts_AIObserver.sql     # Icon font registrations
│   ├── JFDMiniMaps_AIObserver.sql      # Minimap type definitions
│   ├── JFDPolicyBranches_AIObserver.sql  # Policy branch data
│   ├── JFDReligions_AIObserver.sql     # Religion color definitions
│   └── Overlay Maps/
│       ├── JFDMaster_OverlayMaps.sql           # Overlay map table schema
│       ├── JFDOverlayMapClasses_OverlayMaps.sql  # Class definitions (e.g. "Players", "Religions")
│       ├── JFDOverlayMapFilters_OverlayMaps.sql  # Filter entries per class
│       ├── JFDOverlayMapOptions_OverlayMaps.sql  # Per-overlay options
│       ├── JFDOverlayMaps_Diplomacy_OverlayMaps.sql  # Diplomacy overlay data
│       ├── JFDOverlayMaps_Players_OverlayMaps.sql    # Player overlay data
│       ├── JFDIconFonts_OverlayMaps.sql        # Icon fonts for overlays
│       └── JFDGameText_*.xml                   # Localized strings for overlays
│
└── Lua/
    ├── JFD_AIObserver_Functions.lua    # Main entry point (event hooks, UI wiring)
    ├── JFD_AIObserver_Functions.xml    # Layout for Functions addin
    ├── JFD_UI_BigMiniMapOverview.lua   # Big minimap popup controller
    ├── JFD_UI_BigMiniMapOverview.xml   # Big minimap popup layout
    ├── JFD_UI_MiniMapOverview.lua      # Simple minimap popup controller
    ├── JFD_UI_MiniMapOverview.xml      # Simple minimap popup layout
    ├── JFD_UI_OverlayMapsOverview.lua  # Overlay maps popup controller
    ├── JFD_UI_OverlayMapsOverview.xml  # Overlay maps popup layout
    ├── Utilities/
    │   ├── JFD_AIObserver_Utils.lua        # Shared helpers
    │   ├── JFD_AIObserver_Minimap_Utils.lua # Minimap helpers
    │   └── JFD_OverlayMaps_Utils.lua       # Overlay map helpers
    └── UI/
        ├── MiniMap/        # Custom minimap panel (imported, overrides base)
        └── Overrides/      # Base-game UI overrides (TopPanel, DiploCorner, etc.)
```

---

## Component Map

### 1. Minimap System

The centerpiece of the mod. Two popups are available:

| Component | File | Description |
|-----------|------|-------------|
| Big Minimap | `JFD_UI_BigMiniMapOverview.lua/.xml` | Full-screen overlay with color-coded territory, cities, units, religion, terrain |
| Simple Minimap | `JFD_UI_MiniMapOverview.lua/.xml` | Lighter popup, toggle from the Additional Information menu |
| Minimap Panel | `Lua/UI/MiniMap/MiniMapPanel.lua/.xml` | Custom replacement for the base-game minimap panel (imported) |
| Minimap Utilities | `Lua/Utilities/JFD_AIObserver_Minimap_Utils.lua` | Mod detection, legend lookups, terrain/feature ID |

**Big Minimap features:**
- Color-coded tiles: land, mountain, water, coast, ocean, ice, player territory, religion majority
- Per-player perspective filter ("Show As" dropdown)
- Toggle checkboxes: Show All Revealed, Barbarians, Cities, Units, Water Tiles
- Collapsible legend sections: Civs, City States, Religions
- CBR resolution support (180×94 minimap)
- Dynamic color assignment from game civilization and religion data

### 2. Overlay Maps System

An extensible framework for displaying complex game-state information as color-coded map overlays. See [overlay-maps.md](overlay-maps.md) for the full schema.

| Component | File | Description |
|-----------|------|-------------|
| Overlay Maps UI | `JFD_UI_OverlayMapsOverview.lua/.xml` | Main popup with class/filter selection |
| Overlay Utilities | `Lua/Utilities/JFD_OverlayMaps_Utils.lua` | Color assignment, legend management |
| SQL Schema | `Core/Overlay Maps/*.sql` | Classes, filters, options, data rows |

Built-in overlay classes include: Players, Religions, Diplomacy, Stability, Ideologies, Cultural Influence.

### 3. Popup & Notification Suppression

Controlled by two game options (set in `JFDGameOptions_AIObserver.sql`):

| Option | Key | Effect |
|--------|-----|--------|
| Suppress Notifications | `GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_NOTIFS` | Silences ancient ruins and archaeology notifications |
| Suppress Popups | `GAMEOPTION_JFD_AIOBSERVER_SUPPRESS_POPUPS` | Auto-dismisses golden age, great person, new era, and other game message popups |

Handler: `JFD_AIObserver_NotificationAdded()` and `JFD_AIObserver_SerialEventGameMessagePopup()` in `JFD_AIObserver_Functions.lua`.

### 4. UI Integration

The mod overrides several base-game UI files (marked `import="1"` in the modinfo):

| File | Purpose |
|------|---------|
| `Lua/UI/MiniMap/MiniMapPanel.lua/.xml` | Custom minimap panel |
| `Lua/UI/Overrides/TopPanel.lua/.xml` | Custom top panel with observer buttons |
| `Lua/UI/Overrides/TopPanel_Back.lua` | Top panel background layer |
| `Lua/UI/Overrides/DiploCorner.lua/.xml` | Diplomacy corner integration |
| `Lua/UI/Overrides/CityBannerManager.lua/.xml` | City banner display |
| `Lua/UI/Overrides/NewTurn.lua/.xml` | New turn event handling |
| `Lua/UI/Overrides/InfoCorner.lua/.xml` | Info corner element |
| `Lua/UI/Overrides/TurnProcessing.lua/.xml` | Turn event processing |

### 5. Utility Framework (`JFD_AIObserver_Utils.lua`)

Shared library used by all UI components:

- **Debug:** Stack trace generation, `JFD_Log()`
- **Mod detection:** IGE, Info Addict, CulDiv, Sovereignty, VMC, JFDLL
- **Math:** Random numbers, rounding
- **Notifications:** Custom world event sending
- **Players:** Leader flavor extraction, ideology/government detection
- **Cities:** Descriptor generation (resistance, puppet, colony), population classification
- **Religion:** Majority detection, main religion identification
- **Ranking:** Score-based ranking with color tiers (Gold, Silver, Bronze, Coal, Iron)

---

## Data Flow

```
Game Engine Events
        │
        ▼
Event Hooks (JFD_AIObserver_Functions.lua)
  ├── Events.LoadScreenClose      → wires UI buttons, moves IGE button
  ├── Events.NotificationAdded    → suppresses goody hut / archaeology notifs
  └── Events.SerialEventGameMessagePopup → suppresses popups
        │
        ▼
UI Popups (opened by user or auto-shown)
  ├── JFD_UI_BigMiniMapOverview.lua   ─→ RefreshMiniMapOverview()
  ├── JFD_UI_MiniMapOverview.lua      ─→ RefreshMiniMapOverview()
  └── JFD_UI_OverlayMapsOverview.lua  ─→ RefreshOverlayMaps()
        │
        ▼
Utility Helpers
  ├── JFD_AIObserver_Utils.lua        (player/city/religion/ranking)
  ├── JFD_AIObserver_Minimap_Utils.lua (terrain, legend, mod detection)
  └── JFD_OverlayMaps_Utils.lua       (color assignment, filter logic)
        │
        ▼
Database (runtime SQL queries via DB.Query / DB.SelectWhere)
  ├── JFD_MinimapOverlays, JFD_CityDescriptors, Leader_Flavors, ...
  └── Loaded OnModActivated from Core/*.sql
        │
        ▼
Visual Rendering
  └── Map tile coloring, legend generation, player/religion color tables
```

---

## Mod Loading Sequence

1. **`OnModActivated`** — Civ5 runs all `UpdateDatabase` actions in order, loading SQL and XML into the game database.
2. **`InGameUIAddin`** entry points load into the UI layer when a game session starts:
   - `JFD_AIObserver_Functions.xml` (includes `JFD_AIObserver_Functions.lua`)
   - `JFD_UI_BigMiniMapOverview.lua`
3. Imported files (`import="1"`) replace base-game files at load time.
4. `Events.LoadScreenClose` fires → mod performs its UI setup.
