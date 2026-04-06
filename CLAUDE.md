# CLAUDE.md — AI Observer Interface

## Project Purpose

This is a fork of **JFD's Utilities — AI Observer Interface (v11)**, a Civ5 mod for spectating AI-only games. We are adapting it for [vox-deorum](https://github.com/CIVITAS-John/vox-deorum), which runs LLMs as Civ5 AI players.

**Adaptation goal:** Display LLM player decisions and reasoning in the game UI as turns unfold — making LLM-vs-LLM games observable and interpretable.

---

## What NOT to Change Without Discussion

- **`JFD's Utilities - AI Observer Interface (v 11).modinfo`** — especially the mod ID (`970aae10-1004-4c8a-af2d-8d601de5ec02`), which is used for mod resolution. Changing it breaks compatibility.
- **Original JFD logic** in any file — we are adding to the mod, not rewriting it. Preserve JFD's implementations verbatim unless there is a specific bug to fix.
- **`CreditsInfo.txt`** — JFD must remain credited as primary author.

---

## Key File Map

```
(3b) AI Observer Interface/
├── JFD's Utilities - AI Observer Interface (v 11).modinfo   # Mod metadata & file list
├── CreditsInfo.txt                                           # Author credits
├── README.md                                                 # Project overview
├── CLAUDE.md                                                 # This file
├── docs/                                                     # Extended documentation
│   ├── architecture.md
│   ├── lua-reference.md
│   └── overlay-maps.md
│
├── Art/                          # DDS textures, font icons, UI images
├── Core/                         # SQL schema + XML game text
│   └── Overlay Maps/             # Overlay map data tables
│
└── Lua/
    ├── JFD_AIObserver_Functions.lua        # Entry point; event hooks
    ├── JFD_AIObserver_Functions.xml        # UI layout for Functions
    ├── JFD_UI_BigMiniMapOverview.lua       # Full-screen minimap popup
    ├── JFD_UI_BigMiniMapOverview.xml
    ├── JFD_UI_MiniMapOverview.lua          # Simple minimap popup
    ├── JFD_UI_MiniMapOverview.xml
    ├── JFD_UI_OverlayMapsOverview.lua      # Overlay maps popup
    ├── JFD_UI_OverlayMapsOverview.xml
    ├── Utilities/
    │   ├── JFD_AIObserver_Utils.lua        # Shared helpers (ranking, cities, religion)
    │   ├── JFD_AIObserver_Minimap_Utils.lua # Minimap-specific helpers
    │   └── JFD_OverlayMaps_Utils.lua       # Overlay map helpers
    └── UI/
        ├── MiniMap/              # Custom minimap panel (imported)
        └── Overrides/            # Base-game UI file overrides
```

---

## Coding Conventions

- **Naming:** All mod-specific globals use `JFD_` prefix (e.g. `JFD_GetPlayerRank`, `JFD_AIObserver_NotificationAdded`). New vox-deorum additions should use a distinct prefix — suggest `VD_` — to avoid collisions.
- **Language:** Lua 5.1 (Civ5 embedded interpreter). No external libraries.
- **UI:** Civ5 uses XML layout files paired with `.lua` controllers. Each UI popup has a `.lua` + `.xml` pair.
- **Database access:** Runtime SQL queries via `DB.Query()` and `DB.SelectWhere()`. Schema defined in `Core/*.sql`, loaded `OnModActivated`.
- **Event system:** `Events.*` (C++ engine events) and `LuaEvents.*` (Lua-to-Lua). Use `Events.EventName.Add(handler)` to register.
- **No print in production** — use `JFD_Log()` from `JFD_AIObserver_Utils.lua` for debug output.
- **Prefer already-allowed tools and simple shell commands** to reduce extra permission prompts. Use Read/Edit/Write/Grep/Glob TOOL instead of Bash commands. When Bash is needed, use simple well-known commands (`ls`, `dotnet build`, `git`) rather than complex pipelines.
- **Never `cd` into the repo.** The repo root is already the working directory. Run all scripts and commands directly (e.g. `python update_md5.py`, `./luacheck.exe ...`).

---

## Testing / Reloading

Civ5 does not hot-reload mods mid-game. To test Lua changes:
1. Modify the `.lua` file.
2. Run luacheck and fix any warnings (see below).
3. Ask the user to test the game.

### Luacheck

The repo root is already the working directory, so run luacheck directly — **do not `cd`**:

```bash
./luacheck.exe Lua/**/*.lua
```

If you need to check a single file, use its relative path from the repo root:

```bash
./luacheck.exe Lua/UI/Overrides/TopPanel.lua
```

---

## Post-Task: Sync Modinfo MD5s

**After completing any task** that creates, edits, or removes files tracked by the mod, sync MD5 hashes — **do not `cd`**:

```bash
python update_md5.py
```

This rewrites every `md5=` attribute in `JFD's Utilities - AI Observer Interface (v 11).modinfo` to match the current file on disk. Civ5 validates these hashes at load time — a stale hash causes the file to be silently ignored by the engine.

Run this as the final step before handing work back to the user, even if you think no tracked file changed.

---

## vox-deorum Integration Notes

- The vox-deorum TypeScript backend communicates with the Civ5 Lua layer via named pipes or file I/O (see vox-deorum repo for protocol details).
- New UI panels for LLM action display should follow the existing popup pattern: `.lua` controller + `.xml` layout, registered as `InGameUIAddin` in the `.modinfo`.
- Overlay map entries for LLM actions can be added via new SQL rows in `Core/Overlay Maps/` following the existing schema — see [docs/overlay-maps.md](docs/overlay-maps.md).
