class_name GameManager
extends Node

signal turn_started(turn: int)
signal turn_ended(turn: int)
signal player_stats_updated
signal event_occurred(title: String, description: String)
signal battle_report(report: String)
signal country_selected(country: Country)
signal victory_achieved(type: String, message: String)
signal achievement_unlocked(title: String)

var current_turn: int = 1
var player_country: Country = null
var countries: Dictionary = {}
var last_event: String = ""
var last_battle_report: String = ""
var game_started: bool = false
var selected_target_id: String = "BR"
var minister_candidates: Array = []
var achievements: Achievements = Achievements.new()

const SAVE_PATH := "user://savegame.json"

func _ready() -> void:
	_create_world()
	achievements.unlocked.connect(func(_id, title): achievement_unlocked.emit(title))
	var start_id = "AR"
	if ProjectSettings.has_setting("game/start_country"):
		start_id = str(ProjectSettings.get_setting("game/start_country"))
	if countries.has(start_id):
		select_country(start_id)
	elif countries.has("AR"):
		select_country("AR")
	elif countries.size() > 0:
		select_country(countries.keys()[0])
	minister_candidates = Cabinet.generate_candidates()
	print("[GameManager] World ready with %d countries" % countries.size())

func _create_world() -> void:
	countries = WorldData.load_countries()
	if countries.is_empty():
		push_error("GameManager: no countries loaded")

func select_country(id: String) -> bool:
	if not countries.has(id):
		return false
	player_country = countries[id]
	game_started = true
	_setup_player_relations()
	var others = get_other_countries()
	if not others.is_empty():
		selected_target_id = others[0].id
	minister_candidates = Cabinet.generate_candidates()
	country_selected.emit(player_country)
	player_stats_updated.emit()
	return true

func _setup_player_relations() -> void:
	var p = player_country
	for id in countries.keys():
		if id == p.id:
			continue
		var base = 15.0 + WorldData.get_region_bonus(p.id, id, countries)
		p.diplomacy.set_relation(id, clampf(base + randf_range(-12.0, 12.0), -80.0, 80.0))

func get_country_list() -> Array:
	var list: Array = []
	for c in countries.values():
		list.append({"id": c.id, "name": c.name, "gdp": c.economy.gdp, "power": c.military.total_power, "pop": c.population})
	list.sort_custom(func(a, b): return a.name < b.name)
	return list

func get_playable_ids() -> Array[String]:
	var ids: Array[String] = []
	for id in countries.keys():
		ids.append(id)
	ids.sort()
	return ids

func get_other_countries() -> Array:
	var list: Array = []
	for c in countries.values():
		if player_country and c.id == player_country.id:
			continue
		list.append(c)
	list.sort_custom(func(a, b): return a.name < b.name)
	return list

func set_target(id: String) -> void:
	if countries.has(id) and (not player_country or id != player_country.id):
		selected_target_id = id

func get_target() -> Country:
	return countries.get(selected_target_id, null)

func hire_first_available_minister() -> String:
	if not player_country:
		return "No country"
	for cand in minister_candidates:
		if cand is Minister and not player_country.cabinet.has_role(cand.role):
			if player_country.economy.treasury < cand.salary * 2.0:
				return "Need more treasury to hire"
			player_country.economy.treasury -= cand.salary
			player_country.cabinet.hire(cand)
			achievements.check(player_country, current_turn)
			player_stats_updated.emit()
			return "Hired %s as %s (skill %.1f)" % [cand.display_name, cand.role_name(), cand.skill]
	return "Cabinet full or no candidates"

func invest_development(sector: String) -> bool:
	if not player_country:
		return false
	var ok = player_country.development.invest(sector, 12.0, player_country.economy)
	if ok:
		achievements.check(player_country, current_turn)
		player_stats_updated.emit()
	return ok

func next_turn() -> void:
	if not player_country:
		return
	print("\n========== TURN %d ==========" % current_turn)
	for country in countries.values():
		country.process_turn()
		AIController.process_country(country, countries, player_country)
	_try_random_event()
	_check_victory()
	achievements.check(player_country, current_turn)
	current_turn += 1
	turn_ended.emit(current_turn - 1)
	turn_started.emit(current_turn)
	player_stats_updated.emit()

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
	return result.report

func diplomats_to_target() -> bool:
	var t = get_target()
	if not t or not player_country:
		return false
	var bonus = player_country.cabinet.skill_of(Minister.Role.FOREIGN)
	var ok = player_country.diplomacy.send_diplomats(t.id, player_country.economy)
	if ok and bonus > 1.0:
		player_country.diplomacy.improve_relation(t.id, (bonus - 1.0) * 3.0)
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
		{"title": "Earthquake", "desc": "Natural disaster damages infrastructure.", "effect": "quake"},
	]
	var e = events[randi() % events.size()]
	last_event = e.title + ": " + e.desc
	_apply_event(e.effect)
	event_occurred.emit(e.title, e.desc)

func _apply_event(effect: String) -> void:
	var c = player_country
	match effect:
		"boom":
			c.economy.gdp += 12.0; c.economy.treasury += 15.0; c.approval = minf(c.approval + 4.0, 100.0)
		"drought":
			c.economy.food = maxf(c.economy.food - 30.0, 0.0); c.stability = maxf(c.stability - 5.0, 0.0)
		"oil":
			c.economy.oil += 40.0; c.economy.energy_level += 0.25; c.economy.treasury += 10.0
		"protests":
			c.approval = maxf(c.approval - 8.0, 0.0); c.stability = maxf(c.stability - 6.0, 0.0)
		"tech":
			c.economy.science_level += 0.2; c.development.science += 0.1
		"fdi":
			c.economy.industry_level += 0.15; c.economy.treasury += 18.0
		"drill":
			c.military.training_level = minf(c.military.training_level + 0.15, 3.5); c.military._recalculate_power()
		"scandal":
			var mit = 1.0 - (c.cabinet.skill_of(Minister.Role.JUSTICE) - 1.0) * 0.2
			c.approval = maxf(c.approval - 10.0 * mit, 0.0)
		"trade":
			c.economy.treasury += 12.0; c.economy.gdp += 5.0
		"refugees":
			c.population += 0.3; c.economy.food = maxf(c.economy.food - 15.0, 0.0)
		"cyber":
			c.economy.gdp = maxf(c.economy.gdp - 8.0, 5.0)
		"olympics":
			c.approval = minf(c.approval + 8.0, 100.0); c.development.sports += 0.15
		"quake":
			c.development.infrastructure = maxf(c.development.infrastructure - 0.2, 0.5)
			c.economy.treasury = maxf(c.economy.treasury - 20.0, 0.0)
			c.stability = maxf(c.stability - 8.0, 0.0)

func _check_victory() -> void:
	if not player_country:
		return
	var c = player_country
	if c.economy.gdp >= 8000.0 and c.economy.treasury >= 1500.0:
		victory_achieved.emit("economic", "Economic Superpower!")
	if c.military.total_power >= 15000.0:
		victory_achieved.emit("military", "Military Hegemony!")
	if c.development.religion_influence >= 95.0 and current_turn >= 30:
		victory_achieved.emit("religious", "Your faith spans the globe!")
	if c.development.ideology_score >= 95.0 and c.stability >= 85.0 and current_turn >= 35:
		victory_achieved.emit("ideological", "Perfect Society achieved!")
	if c.stability >= 90.0 and c.approval >= 85.0 and current_turn >= 50:
		victory_achieved.emit("legacy", "Beloved leader of a golden age.")

func save_game() -> bool:
	if not player_country:
		return false
	var data = {"version": 5, "turn": current_turn, "player_id": player_country.id, "target": selected_target_id, "achievements": achievements.unlocked_ids, "countries": {}}
	for id in countries.keys():
		var c: Country = countries[id]
		data.countries[id] = {
			"population": c.population, "stability": c.stability, "approval": c.approval,
			"gdp": c.economy.gdp, "treasury": c.economy.treasury, "tax_rate": c.economy.tax_rate, "debt": c.economy.debt,
			"food": c.economy.food, "oil": c.economy.oil, "iron": c.economy.iron, "uranium": c.economy.uranium,
			"industry": c.economy.industry_level, "agriculture": c.economy.agriculture_level,
			"energy": c.economy.energy_level, "science": c.economy.science_level,
			"infantry": c.military.infantry, "tanks": c.military.tanks, "aircraft": c.military.aircraft, "navy": c.military.navy,
			"training": c.military.training_level, "nuclear": c.military.nuclear_progress, "has_nuke": c.military.has_nuclear_weapons,
			"relations": c.diplomacy.relations.duplicate(), "alliances": c.diplomacy.alliances.duplicate(), "at_war": c.diplomacy.at_war_with.duplicate(),
			"edu": c.development.education, "infra": c.development.infrastructure, "cult": c.development.culture,
			"just": c.development.justice, "rel": c.development.religion_influence, "ideo": c.development.ideology_score,
		}
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return false
	_create_world()
	current_turn = int(data.get("turn", 1))
	selected_target_id = str(data.get("target", "BR"))
	var ach: Array = data.get("achievements", [])
	achievements.unlocked_ids.clear()
	for a in ach:
		achievements.unlocked_ids.append(str(a))
	var saved: Dictionary = data.get("countries", {})
	for id in saved.keys():
		if not countries.has(id):
			continue
		var s: Dictionary = saved[id]
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
		c.development.education = float(s.get("edu", 1))
		c.development.infrastructure = float(s.get("infra", 1))
		c.development.culture = float(s.get("cult", 1))
		c.development.justice = float(s.get("just", 1))
		c.development.religion_influence = float(s.get("rel", 30))
		c.development.ideology_score = float(s.get("ideo", 50))
	select_country(str(data.get("player_id", "AR")))
	player_stats_updated.emit()
	return true
