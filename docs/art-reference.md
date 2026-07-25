# Art reference

Only assets referenced by a surviving layout or icon mapping are shipped.

## Font-icon sheets

### `JFDFontIcons_AIObserver_22`

Registered mappings:

| Glyph | Mapping |
|---:|---|
| 1–4 | `ICON_GOLD_POS`, `ICON_GOLD_NEG`, `ICON_GOLD_EMP`, `ICON_GOLD_NEU` |
| 13 | `ICON_IDEOLOGY_A` |
| 23 | `ICON_CITY` |
| 24 | `ICON_PANTHEON_A` |

### `JFDFontIcons_Players_OverlayMaps_22`

Only glyph 2, `ICON_LEGEND_ANARCHY`, is registered. The legacy filename remains because the live
stability display uses that glyph; the removed overlay-map framework does not ship.

## UI textures

| Texture | Live use |
|---|---|
| `topleftaiobserver3.dds` | Main top-left observer panel |
| `topleft2_aiobserver2.dds` | Stat-row backing |
| `aiobserversymbolframe32.dds` | Ideology and religion frames |
| `aiobserversymbolrankedframe32.dds` | War-relation civ frames |
| `overlaymapbutton.dds`, `overlaymapbuttonhl.dds` | Full-screen minimap button and hover state |
| `IGEButton.dds`, `IGEButtonHL.dds` | Optional IGE minimap button and hover state |
| `bottomright128x224_2.dds` | Minimap corner referenced by `MiniMapPanel.xml` |

Font sheets require their paired `.ggxml` descriptors. Every texture and descriptor must also be
listed in the modinfo `<Files>` section.
