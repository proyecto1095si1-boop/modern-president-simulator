# Modern President Simulator

Open-source mobile geopolitical strategy game inspired by *MA 3 – President Simulator*.

Lead a modern nation: economy, military, diplomacy, nuclear program, wars and random events.
Built with **Godot 4** (Android / iOS / Desktop).

**https://github.com/proyecto1095si1-boop/modern-president-simulator**

---

## Status — **v0.3 Playable Loop**

### Implemented
- [x] Turn-based simulation
- [x] Economy (taxes, GDP, treasury, debt, resources, investments)
- [x] Military (recruit, train, nuclear, maintenance, power)
- [x] Diplomacy (relations, diplomats, embassies, alliances, peace)
- [x] Turn-based **battles** with losses and political effects
- [x] 14 countries
- [x] Switch playable nation
- [x] Target selection for diplomacy / war
- [x] Random events (12 types)
- [x] Victory conditions (Economic / Military / Ideological)
- [x] **Save / Load**
- [x] Mobile-oriented UI

### Next
- [ ] AI countries that act on their own
- [ ] World map view
- [ ] Dedicated country selection menu
- [ ] Android export preset

---

## How to play

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Open `project.godot` → **F5**
3. Start as Argentina (**Switch Nation** to change)
4. **◀ Target / Target ▶** to choose who you interact with
5. Diplomats / Embassy / Alliance / **ATTACK** / Offer Peace
6. Grow economy & army → **Next Turn**
7. **Save** / **Load** anytime

---

## Core files

| File | Role |
|------|------|
| `GameManager.gd` | World, turns, events, battles, save/load |
| `Battle.gd` | Combat resolution |
| `Economy.gd` / `Military.gd` / `Diplomacy.gd` | Systems |
| `MainUI.gd` | UI controller |

---

## License

MIT. Not affiliated with Oxiwyle Inc.
