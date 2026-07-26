# Dead-code cleanup

The stage-2 cleanup is complete.

Removed in this pass:

- the unreachable vanilla `TopPanel.lua` update/tooltip block while preserving all live stat
  click handlers;
- hidden top-panel buttons, score/ranking UI, duplicate stat stacks, obsolete civ buttons, and
  decorative controls that could never be shown;
- unused JFD helpers for flavors, governments, religions, score ranking, city descriptors,
  debugging, and unrelated mod detection;
- the city-descriptor schema/data file and its load-time query;
- orphaned game options, localized strings, colors, and icon mappings;
- inert overlay-overview firing sites and duplicate hidden addin controls;
- the permanently hidden vanilla DiploCorner cluster, leaving only reachable multiplayer chat;
- empty minimap refresh/active-player handlers and the non-rendering new-turn controller;
- unused includes, locals, callback arguments, loop indices, and constant initializers reported by
  static analysis;
- the anarchy/dark-age status branches, colors, and permanently unused age-state backgrounds;
- 15 textures and the legacy overlay-font descriptor whose final live references were removed.

Deliberately retained:

- `bottomright128x224_2.dds` because `MiniMapPanel.xml` still resolves it by basename;
- the standard minimap map-option code and League Overview code, both of which remain reachable
  through visible controls and engine events.

The cleanup was checked with Lua static analysis, XML parsing, manifest/file reconciliation, SQL
reference scans, and a repository-wide asset reference scan. Civ5 UI behavior still requires an
in-game smoke test because the embedded Lua/XML runtime is not available outside the game.
