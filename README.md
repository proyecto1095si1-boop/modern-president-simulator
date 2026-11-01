# Modern President Simulator

**Open-source mobile strategy game** inspired by *MA 3 – President Simulator* (Oxiwyle).

Become the leader of a modern nation. Manage the economy, build your military, conduct diplomacy, research technologies, and pursue different paths to victory.

Built with **Godot 4** for excellent mobile performance (Android / iOS).

---

## Current Status — **v0.2 Playable Prototype**

### Working now
- [x] Turn-based simulation loop
- [x] Full Economy system (taxes, GDP, treasury, debt, resources, investments in industry / agriculture / energy / science)
- [x] Military system (infantry, tanks, aircraft, navy, training, nuclear program, maintenance)
- [x] Diplomacy data model (relations, alliances, wars)
- [x] Random events system (economic boom, drought, oil discovery, protests, scandals, etc.)
- [x] 9 countries in the world (Argentina playable + Brazil, Chile, Uruguay, Peru, USA, China, Russia, Germany)
- [x] Mobile-oriented UI with all main actions
- [x] Real-time feedback of stats after every action and turn

### Next priorities
- [ ] Country selection screen
- [ ] Interactive diplomacy (improve relations, form alliances, declare war)
- [ ] Simple turn-based battles
- [ ] Map view
- [ ] Save / Load
- [ ] More events and disasters
- [ ] Victory conditions

---

## How to Play (right now)

1. Install [Godot 4.3+](https://godotengine.org/download)
2. Clone the repo and open `project.godot`
3. Press **F5**
4. You start as **Argentina**
5. Use the buttons:
   - **Next Turn** → advance time, process economy/military, chance of random event
   - **Tax + / Tax -** → change tax rate
   - **Invest Industry / Agri / Energy** → grow production
   - **Recruit Infantry / Tanks** → expand army (costs money + iron for tanks)
   - **Train Army** → improve training level
   - **Nuclear Research** → advance nuclear program
   - **Take Loan** → get quick money (increases debt)

Watch the console for detailed logs each turn.

---

## Project Structure

```
scripts/core/
  GameManager.gd   → turns, world, events
  Country.gd       → nation data
  Economy.gd       → production, taxes, resources, investments
  Military.gd      → units, training, nuclear, power calculation
  Diplomacy.gd     → relations & alliances

scripts/ui/
  MainUI.gd        → all buttons and labels

scenes/main/
  Main.tscn        → main playable scene
```

---

## Inspiration

- MA 3 – President Simulator (Oxiwyle)
- Open-source projects: HAKEEM243/Pr-sident-, ArpitPy/nation-simulator, Nashet/Prosperity-Wars, Gamowy/Civ2025

This is an independent open-source project and is **not** affiliated with Oxiwyle Inc.

---

## License

MIT License
