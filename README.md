# Modern President Simulator

**Open-source mobile strategy game** inspired by *MA 3 – President Simulator* (Oxiwyle).

Become the leader of a modern nation. Manage the economy, build your military, conduct diplomacy, research technologies, and pursue different paths to victory (Military, Economic, Ideological, or Soft Power).

Built with **Godot 4** for excellent mobile performance (Android / iOS) and easy cross-platform development.

---

## Vision

A deep but approachable geopolitical nation simulator focused on modern-era gameplay:

- **Economy**: Taxes, production of resources (food, oil, iron, uranium...), factories, loans, trade.
- **Military**: Army recruitment & training, turn-based battles, nuclear program, espionage & sabotage.
- **Diplomacy**: Alliances, pacts, embassies, UN votes, sanctions, naval blockades.
- **Development**: Education, infrastructure, science, culture, housing, justice, ideology & religion.
- **Victory conditions**: Conquer the world, spread your ideology/religion, or dominate economically.

The game is designed to be fully playable offline.

---

## Current Status (v0.1 – Foundation)

- [x] Repository & project structure
- [x] Core data models (Country, Resources, Government)
- [x] Turn-based GameManager skeleton
- [x] Basic economy simulation loop
- [ ] Map / country selection
- [ ] Military system & battles
- [ ] Diplomacy system
- [ ] Full UI (mobile-first)
- [ ] Save / Load
- [ ] Events & disasters
- [ ] Multiple victory paths

---

## Tech Stack

- **Engine**: Godot 4.3+
- **Language**: GDScript (with optional C# later)
- **Architecture**: Component-based + Event-driven
- **Data**: JSON / Resource files for countries, technologies, events
- **Target**: Android (primary), iOS, Desktop, Web

---

## How to Run

1. Install [Godot 4.3 or newer](https://godotengine.org/download)
2. Clone this repository
3. Open the project in Godot (`project.godot`)
4. Press F5 or click Play

---

## Project Structure

```
modern-president-simulator/
├── project.godot
├── README.md
├── docs/
│   └── design.md
├── data/
│   ├── countries/
│   ├── technologies/
│   └── events/
├── scenes/
│   ├── main/
│   ├── ui/
│   └── map/
├── scripts/
│   ├── core/
│   │   ├── GameManager.gd
│   │   ├── Country.gd
│   │   ├── Economy.gd
│   │   ├── Military.gd
│   │   └── Diplomacy.gd
│   ├── systems/
│   └── ui/
└── assets/
```

---

## Inspiration & Credits

Inspired by:
- MA 3 – President Simulator (Oxiwyle)
- Open-source projects: `HAKEEM243/Pr-sident-`, `ArpitPy/nation-simulator`, `Nashet/Prosperity-Wars`, `Gamowy/Civ2025`

This is an independent open-source project and is not affiliated with Oxiwyle Inc.

---

## Contributing

Pull requests are welcome! See the roadmap above and open an issue if you want to work on a specific system.

---

## License

MIT License – free to use, modify and distribute.
