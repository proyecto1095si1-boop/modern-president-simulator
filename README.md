# Modern President Simulator

Open-source Godot 4 geopolitical strategy inspired by **MA 3 – President Simulator** (Oxiwyle), improved where players complain (ads, relation decay, shallow long-term play).

**https://github.com/proyecto1095si1-boop/modern-president-simulator**

---

## v0.6 — What’s in the box

### Screens
- **Main Menu** — New Game / Continue / Quit (dark geopolitical theme)
- **Country Select** — searchable list of ~130 nations + stat preview
- **Command HUD** — economy, military, diplomacy, war, system
- **World Map** — pan/scroll, region blocks, color-coded markers

### Systems (MA3 parity + improvements)
| System | Status |
|--------|--------|
| Economy (tax, loans, resources, buildings) | Yes |
| Military (units, train, nuclear, battles) | Yes |
| Diplomacy (embassies, alliances, peace) | Yes |
| **Cabinet / Ministers** (7 roles, skills, salaries) | Yes |
| **Development** (edu, infra, science, culture, justice, housing, sports) | Yes |
| **Religion & Ideology** soft-power victory paths | Yes |
| World map + ~130 countries | Yes |
| AI nations | Yes |
| Events (incl. disasters) | Yes |
| Save / Load | Yes |
| Offline, no ads | Yes |

### Victory paths
Military · Economic · Religious · Ideological · Legacy

### Visual identity
- Dark navy / gold accent UI (command-center feel)
- Map: blue = you, yellow = selected, red = war, green = ally, purple = nuclear
- Named minister characters (Elena Vargas, Marcus Chen, Aisha Okonkwo, …)

---

## How to run

1. Install **Godot 4.3+**
2. Open this project
3. Press **F5** → Main Menu → **New Game** → pick a country → play

### In-game
- **MAP** — world map
- Target ◀▶ / Attack / Diplomats / Alliance
- Economy & military investments
- Next Turn advances simulation + AI + events
- Save / Load anytime

### Code helpers (console / extend UI)
```gdscript
game_manager.hire_first_available_minister()
game_manager.invest_development("education")  # or infrastructure, science, culture, justice, religion, ideology
```

---

## vs MA 3 (design choices)

**Kept:** nation sim core, multi-path victory, ministers idea, resources, nuclear, UN-style diplomacy depth roadmap.

**Improved from reviews:** no aggressive ads/subscriptions; relations don’t collapse without cause as fast; disasters exist but aren’t pure progress-wipes; open data files for countries/map; offline-first.

---

## License

MIT — not affiliated with Oxiwyle Inc.
