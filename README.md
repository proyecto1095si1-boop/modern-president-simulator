# Modern President Simulator

Open-source mobile geopolitical strategy game inspired by *MA 3 – President Simulator*.

**https://github.com/proyecto1095si1-boop/modern-president-simulator**

---

## Status — **v0.5 Structured World Map**

### Implemented
- [x] Full simulation loop (economy, military, diplomacy, battles, AI, events)
- [x] **~130 countries** (`data/countries.json`)
- [x] **Structured world map**
  - Coordinates per country (`data/map_coords.json`)
  - Regional blocks (N/S America, Europe, Africa, Asia, Oceania)
  - Scroll/pan canvas 2000×1100
  - Color coding: You / Target / War / Ally / Nuclear
  - Tap country → Set as Target or Play as this nation
- [x] Save / Load, victories, all nations playable

### How to open the map
Press **MAP** in the System row → explore → **Set as Target** or **Play as this** → **Close**

### Map structure
| File | Role |
|------|------|
| `data/map_coords.json` | Normalized x,y for every country |
| `scripts/map/MapController.gd` | Markers, colors, selection |
| `scenes/map/WorldMap.tscn` | Scrollable map UI |

Edit `map_coords.json` to reposition nations without code changes.

---

## How to play

1. Godot 4.3+ → open project → **F5**
2. **MAP** to pick targets / switch nation visually
3. Economy, military, diplomacy, **ATTACK**, **Next Turn**
4. **Save** / **Load**

---

## License

MIT. Not affiliated with Oxiwyle Inc.
