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
│   ├── art-reference.md
│   ├── dead-code.md                                          # Completed footprint cleanup record
│   ├── lua-reference.md
│   └── observer-api.md
│
├── Art/                          # DDS textures, font icons, UI images
├── Core/                         # SQL schema + XML game text
│
└── Lua/
    ├── JFD_AIObserver_Functions.lua        # InGameUIAddin; popup/notification suppression
    ├── JFD_AIObserver_Functions.xml        # Empty host context for Functions
    ├── JFD_UI_BigMiniMapOverview.lua       # Full-screen minimap popup (InGameUIAddin)
    ├── JFD_UI_BigMiniMapOverview.xml
    ├── Utilities/
    │   ├── JFD_AIObserver_Utils.lua        # Minimal helpers (IGE, rounding, ideology)
    │   └── VD_Observer_Utils.lua           # vox-deorum stateless helpers
    └── UI/
        ├── MiniMap/              # Custom minimap panel (imported, overrides base)
        └── Overrides/            # Base-game UI file overrides:
                                  #   TopPanel.*      — top panel AND the civ list
                                  #   TurnProcessing.* — "<model> is thinking" popup
                                  #   LeagueOverview.lua — World Congress (no .xml)
                                  #   DiploCorner.*   — multiplayer chat only
                                  #   NewTurn.*       — suppresses turn-start banner
```

**Footprint policy:** the mod drops everything not needed for vox-deorum, including minimap
overlay modes, city descriptors, score ranking, and religion/government map colouring.
Don't reintroduce a file without adding it to the modinfo `<Files>` list — and note that
`import="0"` on a `.dds` means the engine can never resolve it. The completed cleanup is recorded
in [docs/dead-code.md](docs/dead-code.md).

---

## Coding Conventions

- **Naming:** Preserve the names of retained legacy helpers. New vox-deorum globals use the
  `VD_` prefix (for example, `VD_Log` and `VD_ShowTurnProcessing`) to avoid collisions.
- **Language:** Lua 5.1 (Civ5 embedded interpreter). No external libraries.
- **UI:** Civ5 uses XML layout files paired with `.lua` controllers. Each UI popup has a `.lua` + `.xml` pair.
- **Database access:** Runtime SQL queries via `DB.Query()` and `DB.SelectWhere()`. Schema defined in `Core/*.sql`, loaded `OnModActivated`.
- **Event system:** `Events.*` (C++ engine events) and `LuaEvents.*` (Lua-to-Lua). Use `Events.EventName.Add(handler)` to register.
- **No unconditional print in production** — use `VD_Log()` from `VD_Observer_Utils.lua`.
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
- LLM decisions reach the UI over `LuaEvents` — `VoxDeorumPlayerInfo` and `VoxDeorumAction` are consumed by `TopPanel.lua`, which drives both the rationale box and the civ list. See [docs/observer-api.md](docs/observer-api.md).
- The Overlay Maps subsystem and its legacy font registration have been **removed**. Don't plan
  LLM-action visualisation around it; extend the civ list or add a new `InGameUIAddin` popup
  instead.
