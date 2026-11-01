class_name Country
extends RefCounted

## Nation container: economy, military, diplomacy, cabinet, development.

signal stats_changed

var id: String = ""
var name: String = ""
var flag_code: String = ""
var capital: String = ""
var population: float = 0.0
var territory: float = 0.0

var stability: float = 50.0
var approval: float = 50.0
var ideology: float = 0.0

var economy: Economy = null
var military: Military = null
var diplomacy: Diplomacy = null
var cabinet: Cabinet = null
var development: Development = null

func _init(p_id: String = "", p_name: String = "") -> void:
	id = p_id
	name = p_name
	flag_code = p_id
	economy = Economy.new()
	military = Military.new()
	diplomacy = Diplomacy.new()
	cabinet = Cabinet.new()
	development = Development.new()

func process_turn() -> void:
	if economy:
		economy.process_turn(self)
	if military:
		military.process_turn(self)
	if diplomacy:
		diplomacy.process_turn(self)
	if cabinet:
		cabinet.process_turn(self)
	if development:
		development.process_turn(self)
	
	# Economy minister tax efficiency
	if cabinet:
		var eco_skill = cabinet.skill_of(Minister.Role.ECONOMY)
		if eco_skill > 1.0:
			economy.treasury += economy.gdp * economy.tax_rate * 0.02 * (eco_skill - 1.0)
		var def_skill = cabinet.skill_of(Minister.Role.DEFENSE)
		if def_skill > 1.0:
			military.training_level = minf(military.training_level + 0.02 * (def_skill - 1.0), 3.5)
			military._recalculate_power()
		var sci_skill = cabinet.skill_of(Minister.Role.SCIENCE)
		if sci_skill > 1.0 and military.nuclear_progress > 0.0 and military.nuclear_progress < 100.0:
			military.nuclear_progress = minf(military.nuclear_progress + 0.5 * (sci_skill - 1.0), 100.0)
	
	stability = clampf(stability + randf_range(-1.2, 1.2), 0.0, 100.0)
	approval = clampf(approval + randf_range(-1.5, 1.5), 0.0, 100.0)
	stats_changed.emit()

func get_summary() -> Dictionary:
	return {
		"id": id,
		"name": name,
		"population": population,
		"stability": stability,
		"approval": approval,
		"gdp": economy.gdp if economy else 0.0,
		"treasury": economy.treasury if economy else 0.0,
		"army_power": military.total_power if military else 0.0,
		"religion": development.religion_influence if development else 0.0,
		"ideology": development.ideology_score if development else 0.0,
	}
