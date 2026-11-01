class_name GameManager
extends Node

## Central controller: world, turns, events, battles, diplomacy, save/load.

signal turn_started(turn: int)
signal turn_ended(turn: int)
signal player_stats_updated
signal event_occurred(title: String, description: String)
signal battle_report(report: String)
signal country_selected(country: Country)
signal victory_achieved(type: String, message: String)

var current_turn: int = 1
var player_country: Country = null
var countries: Dictionary = {}   # id -> Country
var last_event: String = ""
var last_battle_report: String = ""
var game_started: bool = false
var selected_target_id: String = "BR"  # default diplomatic/military target

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	_create_sample_world()
	# Default player until user selects
	if not player_country and countries.has("AR"):
		select_country("AR")
	print("[GameManager] World ready with %d countries" % countries.size())

func _create_sample_world() -> void:
	countries.clear()
	
	_add("AR", "Argentina", 46.0, 2780000, 640.0, 85.0, 70, 15, 8, 4, 55.0, 48.0)
	countries["AR"].economy.agriculture_level = 1.4
	countries["AR"].economy.farms = 5
	
	_add("BR", "Brazil", 215.0, 8516000, 2100.0, 180.0, 200, 45, 20, 8, 52.0, 50.0)
	_add("CL", "Chile", 19.5, 756000, 320.0, 55.0, 45, 10, 6, 3, 68.0, 60.0)
	_add("UY", "Uruguay", 3.5, 176000, 75.0, 25.0, 20, 3, 2, 1, 72.0, 65.0)
	_add("PE", "Peru", 34.0, 1285000, 270.0, 40.0, 55, 8, 4, 2, 50.0, 45.0)
	_add("CO", "Colombia", 52.0, 1142000, 350.0, 45.0, 60, 12, 5, 3, 48.0, 42.0)
	_add("MX", "Mexico", 130.0, 1964000, 1400.0, 120.0, 120, 30, 15, 6, 50.0, 47.0)
	
	var us = _add("US", "United States", 335.0, 9834000, 27000.0, 2500.0, 480, 220, 140, 40, 60.0, 55.0)
	us.military.has_nuclear_weapons = true
	us.military.nuclear_progress = 100.0
	
	var cn = _add("CN", "China", 1410.0, 9597000, 18000.0, 1800.0, 900, 350, 200, 50, 65.0, 70.0)
	cn.military.has_nuclear_weapons = true
	cn.military.nuclear_progress = 100.0
	
	var ru = _add("RU", "Russia", 144.0, 17100000, 1900.0, 300.0, 350, 120, 80, 30, 45.0, 50.0)
	ru.military.has_nuclear_weapons = true
	ru.military.nuclear_progress = 100.0
	
	_add("DE", "Germany", 84.0, 357000, 4500.0, 400.0, 80, 25, 30, 5, 70.0, 62.0)
	_add("FR", "France", 68.0, 643000, 3000.0, 280.0, 90, 30, 40, 12, 65.0, 55.0)
	countries["FR"].military.has_nuclear_weapons = true
	countries["FR"].military.nuclear_progress = 100.0
	_add("JP", "Japan", 125.0, 378000, 4200.0, 350.0, 100, 20, 50, 15, 75.0, 60.0)
	_add("IN", "India", 1400.0, 3287000, 3500.0, 200.0, 500, 150, 80, 20, 55.0, 52.0)
	countries["IN"].military.has_nuclear_weapons = true
	countries["IN"].military.nuclear_progress = 100.0

func _add(id: String, name: String, pop: float, territory: float, gdp: float, treasury: float,
		inf: int, tanks: int, air: int, navy: int, stab: float, appr: float) -> Country:
	var c = Country.new(id, name)
	c.population = pop
	c.territory = territory
	c.economy.gdp = gdp
	c.economy.treasury = treasury
	c.military.infantry = inf
	c.military.tanks = tanks
	c.military.aircraft = air
	c.military.navy = navy
	c.stability = stab
	c.approval = appr
	c.military._recalculate_power()
	countries[id] = c
	return c

func select_country(id: String) -> bool:
	if not countries.has(id):
		return false
	player_country = countries[id]
	game_started = true
	_setup_player_relations()
	country_selected.emit(player_country)
	player_stats_updated.emit()
	print("[GameManager] Selected nation: %s" % player_country.name)
	return true

func _setup_player_relations() -> void:
	var p = player_country
	for id in countries.keys():
		if id == p.id:
			continue
		var base = 20.0
		# Neighbours / regional bias (simplified)
		if p.id in ["AR", "BR", "CL", "UY", "PE", "CO"] and id in ["AR", "BR", "CL", "UY", "PE", "CO"]:
			base = 45.0
		p.diplomacy.set_relation(id, base + randf_range(-10.0, 15.0))

func get_country_list() -> Array:
	var list: Array = []
	for c in countries.values():
		list.append({"id": c.id, "name": c.name, "gdp": c.economy.gdp, "power": c.military.total_power})
	list.sort_custom(func(a, b): return a.name < b.name)
	return list

func get_other_countries() -> Array:
	var list: Array = []
	for c in countries.values():
		if player_country and c.id == player_country.id:
			continue
		list.append(c)
	return list

func set_target(id: String) -> void:
	if countries.has(id) and (not player_country or id != player_country.id):
		selected_target_id = id

func get_target() -> Country:
	return countries.get(selected_target_id, null)

# ---------- ACTIONS ----------

func next_turn() -> void:
	if not player_country:
		return
	print("\n========== TURN %d ==========" % current_turn)
	for country in countries.values():
		country.process_turn()
	_try_random_event()
	_check_victory()
	current_turn += 1
	turn_ended.emit(current_turn - 1)
	turn_started.emit(current_turn)
	player_stats_updated.emit()
	_print_player_status()

func attack_target() -> String:
	var target = get_target()
	if not player_country or not target:
		return "No valid target"
	if target.id == player_country.id:
		return "Cannot attack yourself"
	var result = Battle.resolve(player_country, target)
	last_battle_report = result.report
	battle_report.emit(result.report)
	player_stats_updated.emit()
	print("[BATTLE] %s" % result.report)
	return result.report

func diplomats_to_target() -> bool:
	var t = get_target()
	if not t or not player_country:
		return false
	var ok = player_country.diplomacy.send_diplomats(t.id, player_country.economy)
	if ok:
		player_stats_updated.emit()
	return ok

func alliance_with_target() -> bool:
	var t = get_target()
	if not t or not player_country:
		return false
	var ok = player_country.diplomacy.form_alliance(t.id)
	if ok and t.diplomacy:
		t.diplomacy.form_alliance(player_country.id)
		player_stats_updated.emit()
	return ok

func embassy_to_target() -> bool:
	var t = get_target()
	if not t or not player_country:
		return false
	var ok = player_country.diplomacy.open_embassy(t.id, player_country.economy)
	if ok:
		player_stats_updated.emit()
	return ok

func peace_with_target() -> bool:
	var t = get_target()
	if not t or not player_country:
		return false
	var ok = player_country.diplomacy.offer_peace(t.id)
	if ok:
		t.diplomacy.offer_peace(player_country.id)
		player_stats_updated.emit()
	return ok

# ---------- EVENTS ----------

func _try_random_event() -> void:
	if randf() > 0.38:
		return
	var events = [
		{"title": "Economic Boom", "desc": "Strong exports boost the economy.", "effect": "boom"},
		{"title": "Drought", "desc": "Severe drought hits agriculture.", "effect": "drought"},
		{"title": "Oil Discovery", "desc": "New oil reserves found.", "effect": "oil"},
		{"title": "Protests", "desc": "Public discontent rises.", "effect": "protests"},
		{"title": "Tech Breakthrough", "desc": "Scientists make progress.", "effect": "tech"},
		{"title": "Foreign Investment", "desc": "Foreign companies invest.", "effect": "fdi"},
		{"title": "Military Exercise", "desc": "Successful drills raise training.", "effect": "drill"},
		{"title": "Corruption Scandal", "desc": "A scandal damages approval.", "effect": "scandal"},
		{"title": "Trade Deal", "desc": "A favourable trade deal is signed.", "effect": "trade"},
		{"title": "Refugee Crisis", "desc": "Influx of refugees strains resources.", "effect": "refugees"},
		{"title": "Cyber Attack", "desc": "Critical infrastructure was attacked.", "effect": "cyber"},
		{"title": "Olympic Success", "desc": "Athletes bring national pride.", "effect": "olympics"},
	]
	var e = events[randi() % events.size()]
	last_event = e.title + ": " + e.desc
	_apply_event(e.effect)
	event_occurred.emit(e.title, e.desc)
	print("[EVENT] %s - %s" % [e.title, e.desc])

func _apply_event(effect: String) -> void:
	var c = player_country
	match effect:
		"boom":
			c.economy.gdp += 12.0
			c.economy.treasury += 15.0
			c.approval = minf(c.approval + 4.0, 100.0)
		"drought":
			c.economy.food = maxf(c.economy.food - 30.0, 0.0)
			c.economy.agriculture_level = maxf(c.economy.agriculture_level - 0.1, 0.5)
			c.stability = maxf(c.stability - 5.0, 0.0)
		"oil":
			c.economy.oil += 40.0
			c.economy.energy_level += 0.25
			c.economy.treasury += 10.0
		"protests":
			c.approval = maxf(c.approval - 8.0, 0.0)
			c.stability = maxf(c.stability - 6.0, 0.0)
		"tech":
			c.economy.science_level += 0.2
			c.approval = minf(c.approval + 3.0, 100.0)
		"fdi":
			c.economy.industry_level += 0.15
			c.economy.treasury += 18.0
		"drill":
			c.military.training_level = minf(c.military.training_level + 0.15, 3.5)
			c.military._recalculate_power()
		"scandal":
			c.approval = maxf(c.approval - 10.0, 0.0)
			c.stability = maxf(c.stability - 4.0, 0.0)
		"trade":
			c.economy.treasury += 12.0
			c.economy.gdp += 5.0
		"refugees":
			c.population += 0.3
			c.economy.food = maxf(c.economy.food - 15.0, 0.0)
			c.stability = maxf(c.stability - 3.0, 0.0)
		"cyber":
			c.economy.gdp = maxf(c.economy.gdp - 8.0, 5.0)
			c.stability = maxf(c.stability - 4.0, 0.0)
		"olympics":
			c.approval = minf(c.approval + 8.0, 100.0)
			c.stability = minf(c.stability + 3.0, 100.0)

func _check_victory() -> void:
	if not player_country:
		return
	var c = player_country
	# Economic victory
	if c.economy.gdp >= 8000.0 and c.economy.treasury >= 1500.0:
		victory_achieved.emit("economic", "Economic Superpower! Your nation dominates world markets.")
	# Military victory (simplified: very high power)
	if c.military.total_power >= 15000.0:
		victory_achieved.emit("military", "Military Hegemony! No nation can challenge your army.")
	# Stability / soft power
	if c.stability >= 90.0 and c.approval >= 85.0 and current_turn >= 40:
		victory_achieved.emit("ideological", "Perfect Society! Your model is admired worldwide.")

# ---------- SAVE / LOAD ----------

func save_game() -> bool:
	if not player_country:
		return false
	var data = {
		"version": 2,
		"turn": current_turn,
		"player_id": player_country.id,
		"target": selected_target_id,
		"countries": {}
	}
	for id in countries.keys():
		var c: Country = countries[id]
		data.countries[id] = {
			"name": c.name,
			"population": c.population,
			"stability": c.stability,
			"approval": c.approval,
			"gdp": c.economy.gdp,
			"treasury": c.economy.treasury,
			"tax_rate": c.economy.tax_rate,
			"debt": c.economy.debt,
			"food": c.economy.food,
			"oil": c.economy.oil,
			"iron": c.economy.iron,
			"uranium": c.economy.uranium,
			"industry": c.economy.industry_level,
			"agriculture": c.economy.agriculture_level,
			"energy": c.economy.energy_level,
			"science": c.economy.science_level,
			"infantry": c.military.infantry,
			"tanks": c.military.tanks,
			"aircraft": c.military.aircraft,
			"navy": c.military.navy,
			"training": c.military.training_level,
			"nuclear": c.military.nuclear_progress,
			"has_nuke": c.military.has_nuclear_weapons,
			"relations": c.diplomacy.relations.duplicate(),
			"alliances": c.diplomacy.alliances.duplicate(),
			"at_war": c.diplomacy.at_war_with.duplicate(),
		}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	print("[SAVE] Game saved.")
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return false
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return false
	_create_sample_world()
	current_turn = int(data.get("turn", 1))
	selected_target_id = str(data.get("target", "BR"))
	var saved_countries: Dictionary = data.get("countries", {})
	for id in saved_countries.keys():
		if not countries.has(id):
			continue
		var s: Dictionary = saved_countries[id]
		var c: Country = countries[id]
		c.population = float(s.get("population", c.population))
		c.stability = float(s.get("stability", 50))
		c.approval = float(s.get("approval", 50))
		c.economy.gdp = float(s.get("gdp", 100))
		c.economy.treasury = float(s.get("treasury", 50))
		c.economy.tax_rate = float(s.get("tax_rate", 0.25))
		c.economy.debt = float(s.get("debt", 0))
		c.economy.food = float(s.get("food", 100))
		c.economy.oil = float(s.get("oil", 50))
		c.economy.iron = float(s.get("iron", 40))
		c.economy.uranium = float(s.get("uranium", 5))
		c.economy.industry_level = float(s.get("industry", 1))
		c.economy.agriculture_level = float(s.get("agriculture", 1))
		c.economy.energy_level = float(s.get("energy", 1))
		c.economy.science_level = float(s.get("science", 1))
		c.military.infantry = int(s.get("infantry", 50))
		c.military.tanks = int(s.get("tanks", 10))
		c.military.aircraft = int(s.get("aircraft", 5))
		c.military.navy = int(s.get("navy", 3))
		c.military.training_level = float(s.get("training", 1))
		c.military.nuclear_progress = float(s.get("nuclear", 0))
		c.military.has_nuclear_weapons = bool(s.get("has_nuke", false))
		c.military._recalculate_power()
		c.diplomacy.relations = s.get("relations", {})
		c.diplomacy.alliances = s.get("alliances", [])
		c.diplomacy.at_war_with = s.get("at_war", [])
	var pid = str(data.get("player_id", "AR"))
	select_country(pid)
	print("[LOAD] Game loaded at turn %d" % current_turn)
	player_stats_updated.emit()
	return true

func _print_player_status() -> void:
	var c = player_country
	if not c:
		return
	print("Country: %s | Turn: %d" % [c.name, current_turn])
	print("  Pop: %.1f M | Stability: %.1f | Approval: %.1f" % [c.population, c.stability, c.approval])
	print("  GDP: %.1f | Treasury: %.1f | Tax: %.0f%% | Debt: %.1f" % [c.economy.gdp, c.economy.treasury, c.economy.tax_rate * 100, c.economy.debt])
	print("  Army Power: %.0f | Nuclear: %s (%.0f%%)" % [c.military.total_power, str(c.military.has_nuclear_weapons), c.military.nuclear_progress])
	print("  Resources → Food: %.0f | Oil: %.0f | Iron: %.0f | Uranium: %.1f" % [c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium])
	if last_event != "":
		print("  Last Event: %s" % last_event)
	if last_battle_report != "":
		print("  Last Battle: %s" % last_battle_report)
