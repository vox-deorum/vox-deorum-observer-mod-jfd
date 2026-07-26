# JFD's AI Observer Interface

> **Adapted for [vox-deorum](https://github.com/CIVITAS-John/vox-deorum)**
> This fork adapts JFD's Observer Interface to display LLM player actions in real time as part of the vox-deorum project.

---

## Original Mod

**Name:** JFD's Utilities — AI Observer Interface
**Author:** JFD
**Version:** 11
**Mod ID:** `970aae10-1004-4c8a-af2d-8d601de5ec02`

A Civilization V mod that provides an enhanced spectator/observer UI for watching AI-only games.
This fork keeps the compact top panel, civ list, enlarged minimap, and turn indicator needed by
vox-deorum.

---

## Features

- **LLM observer panel** — shows each model-controlled civilization, its live stats, decisions, and rationale
- **Automatic spectating** — follows AI turns and interesting combat/city events while reporting animation metadata
- **Big Minimap Overview** — enlarges the engine minimap in a full-screen popup
- **World Congress observation** — exposes session state and cached resolution results
- **Compact footprint** — removed overlay maps, city descriptors, ranking UI, and unused compatibility layers from the original mod

---

## Adaptation for vox-deorum

[vox-deorum](https://github.com/CIVITAS-John/vox-deorum) is a research project that integrates large language models (GPT, Claude, and local models) as Civilization V AI opponents. LLMs handle macro-strategic reasoning while the existing VPAI handles tactical execution.

This fork adapts the Observer Interface to **surface LLM player decisions in the game UI** — showing what each LLM player chose to do each turn, why, and how that maps to in-game actions. The goal is to make LLM-vs-LLM or LLM-vs-VPAI games observable and interpretable for researchers and spectators.

> **Status:** Under active development. The original JFD observer UI has been reduced to the
> runtime paths used by the vox-deorum integration.

---

## Credits

### Original Mod
| Role | Name |
|------|------|
| Code, Design, Research, Writing | **JFD** |
| Debugging config reference | Modiki ([source](https://modiki.civfanatics.com/index.php?title=Debugging_(Civ5)#Configuration)) |
| UI — Religion Spread | Whoward ([source](http://www.picknmixmods.com/mods/CivV/UI/Religion%20Spread.html)) |

### vox-deorum Adaptation
| Role | Name |
|------|------|
| Adaptation & Integration | CIVITAS-John |

---

## Documentation

- [docs/architecture.md](docs/architecture.md) — system architecture and data flow
- [docs/lua-reference.md](docs/lua-reference.md) — Lua function reference
- [docs/observer-api.md](docs/observer-api.md) — vox-deorum event contract
- [docs/dead-code.md](docs/dead-code.md) — footprint cleanup record

---

## Related Projects

- [vox-deorum](https://github.com/CIVITAS-John/vox-deorum) — LLM AI for Civilization V
- [vox-deorum-replay](https://github.com/CIVITAS-John/vox-deorum-replay) — session replay viewer
- Original mod thread: CivFanatics (JFD's Utilities series)
