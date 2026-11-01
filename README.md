# Modern President Simulator

Open-source mobile geopolitical strategy game inspired by *MA 3 – President Simulator*.

Lead a modern nation: economy, military, diplomacy, nuclear program, wars and random events.
Built with **Godot 4** (Android / iOS / Desktop).

**https://github.com/proyecto1095si1-boop/modern-president-simulator**

---

## Status — **v0.4 Full World**

### Implemented
- [x] Turn-based simulation
- [x] Economy, Military, Diplomacy, Battles
- [x] **~130 countries** with population, GDP, army, nuclear status, region
- [x] Data-driven world: `data/countries.json` + `WorldData.gd`
- [x] **All nations playable** (Switch Nation cycles the full list)
- [x] Target any country for diplomacy / war
- [x] Regional relation bonuses
- [x] AI for non-player nations
- [x] Random events, victories, Save/Load
- [x] Mobile-oriented UI

### Regions covered
North America · South America · Europe · Asia · Middle East · Africa · Oceania

### Next
- [ ] Country selection menu (list/search)
- [ ] World map view
- [ ] Stronger AI (wars between AI)
- [ ] Android export preset

---

## How to play

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open `project.godot` → **F5**
3. Start as Argentina — **Switch Nation** to play any of the ~130 countries
4. **◀ Target / Target ▶** to cycle all other nations
5. Diplomacy, war, economy, military actions
6. **Next Turn** / **Save** / **Load**

---

## Data

Country stats live in:

```
data/countries.json
```

Each entry: `id`, `name`, `pop`, `area`, `gdp`, `treasury`, `inf`, `tanks`, `air`, `navy`, `stab`, `appr`, `nuke`, `region`.

Edit this file to add or balance nations without touching code.

---

## Core files

| File | Role |
|------|------|
| `data/countries.json` | Full world database |
| `WorldData.gd` | JSON loader |
| `GameManager.gd` | Simulation hub |
| `Battle.gd` | Combat |
| `AIController.gd` | AI turns |
| `MainUI.gd` | UI |

---

## License

MIT. Not affiliated with Oxiwyle Inc.
