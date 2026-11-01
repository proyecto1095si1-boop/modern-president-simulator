class_name GameManager
extends Node

## Central controller of the simulation.
## Manages countries, player nation, turns and random events.

signal turn_started(turn: int)
signal turn_ended(turn: int)
signal player_stats_updated
signal event_occurred(title: String, description: String)

var current_turn: int = 1
var player_country: Country = null
var countries: Dictionary = {}   # id -> Country
var last_event: String = ""

func _ready() -> void:
	_create_sample_world()
	print("[GameManager] World created with %d countries" % countries.size())
	print("[GameManager] You are leading: %s" % player_country.name)

func _create_sample_world() -> void:
	# === PLAYER ===
	var ar = _make_country("AR", "Argentina", 46.0, 2780000, 640.0, 85.0, 70, 15, 8, 4)
	ar.stability = 55.0
	ar.approval = 48.0
	ar.economy.agriculture_level = 1.4
	ar.economy.farms = 5
	countries["AR"] = ar
	player_country = ar
	
	# === SOUTH AMERICA ===
	var br = _make_country("BR", "Brazil", 215.0, 8516000, 2100.0, 180.0, 200, 45, 20, 8)
	br.stability = 52.0
	countries["BR"] = br
	
	var cl = _make_country("CL", "Chile", 19.5, 756000, 320.0, 55.0, 45, 10, 6, 3)
	cl.stability = 68.0
	countries["CL"] = cl
	
	var uy = _make_country("UY", "Uruguay", 3.5, 176000, 75.0, 25.0, 20, 3, 2, 1)
	uy.stability = 72.0
	countries["UY"] = uy
	
	var pe = _make_country("PE", "Peru", 34.0, 1285000, 270.0, 40.0, 55, 8, 4, 2)
	countries["PE"] = pe
	
	# === MAJOR POWERS ===
	var us = _make_country("US", "United States", 335.0, 9834000, 27000.0, 2500.0, 480, 220, 140, 40)
	us.military.has_nuclear_weapons = true
	us.military.nuclear_progress = 100.0
	us.stability = 60.0
	countries["US"] = us
	
	var cn = _make_country("CN", "China", 1410.0, 9597000, 18000.0, 1800.0, 900, 350, 200, 50)
	cn.military.has_nuclear_weapons = true
	cn.military.nuclear_progress = 100.0
	countries["CN"] = cn
	
	var ru = _make_country("RU", "Russia", 144.0, 17100000, 1900.0, 300.0, 350, 120, 80, 30)
	ru.military.has_nuclear_weapons = true
	ru.military.nuclear_progress = 100.0
	countries["RU"] = ru
	
	var de = _make_country("DE", "Germany", 84.0, 357000, 4500.0, 400.0, 80, 25, 30, 5)
	de.stability = 70.0
	countries["DE"] = de
	
	# Initial relations for player
	player_country.diplomacy.set_relation("BR", 40.0)
	player_country.diplomacy.set_relation("CL", 60.0)
	player_country.diplomacy.set_relation("UY", 75.0)
	player_country.diplomacy.set_relation("PE", 35.0)
	player_country.diplomacy.set_relation("US", 30.0)
	player_country.diplomacy.set_relation("CN", 25.0)
	player_country.diplomacy.set_relation("RU", 20.0)
	player_country.diplomacy.set_relation("DE", 45.0)

func _make_country(id: String, name: String, pop: float, territory: float, gdp: float, treasury: float, inf: int, tanks: int, air: int, navy: int) -> Country:
	var c = Country.new(id, name)
	c.population = pop
	c.territory = territory
	c.economy.gdp = gdp
	c.economy.treasury = treasury
	c.military.infantry = inf
	c.military.tanks = tanks
	c.military.aircraft = air
	c.military.navy = navy
	c.military._recalculate_power()
	return c

func next_turn() -> void:
	print("\n========== TURN %d ==========" % current_turn)
	
	# Process all countries
	for country in countries.values():
		country.process_turn()
	
	# Random event chance for player
	_try_random_event()
	
	current_turn += 1
	turn_ended.emit(current_turn - 1)
	turn_started.emit(current_turn)
	player_stats_updated.emit()
	
	_print_player_status()

func _try_random_event() -> void:
	if randf() > 0.35:
		return  # 35% chance of event each turn
	
	var events = [
		{"title": "Economic Boom", "desc": "Strong exports boost the economy. +GDP and Treasury.", "effect": "boom"},
		{"title": "Drought", "desc": "Severe drought hits agriculture. Food production suffers.", "effect": "drought"},
		{"title": "Oil Discovery", "desc": "New oil reserves found. Energy sector grows.", "effect": "oil"},
		{"title": "Protests", "desc": "Public discontent rises due to policies.", "effect": "protests"},
		{"title": "Tech Breakthrough", "desc": "Scientists make progress. Science level increases.", "effect": "tech"},
		{"title": "Foreign Investment", "desc": "Foreign companies invest in your industry.", "effect": "fdi"},
		{"title": "Military Exercise", "desc": "Successful drills raise training and morale.", "effect": "drill"},
		{"title": "Corruption Scandal", "desc": "A scandal damages government approval.", "effect": "scandal"},
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

func _print_player_status() -> void:
	var c = player_country
	print("Country: %s | Turn: %d" % [c.name, current_turn])
	print("  Pop: %.1f M | Stability: %.1f | Approval: %.1f" % [c.population, c.stability, c.approval])
	print("  GDP: %.1f | Treasury: %.1f | Tax: %.0f%% | Debt: %.1f" % [c.economy.gdp, c.economy.treasury, c.economy.tax_rate * 100, c.economy.debt])
	print("  Army Power: %.0f | Nuclear: %s (%.0f%%)" % [c.military.total_power, str(c.military.has_nuclear_weapons), c.military.nuclear_progress])
	print("  Resources → Food: %.0f | Oil: %.0f | Iron: %.0f | Uranium: %.1f" % [c.economy.food, c.economy.oil, c.economy.iron, c.economy.uranium])
	if last_event != "":
		print("  Last Event: %s" % last_event)
