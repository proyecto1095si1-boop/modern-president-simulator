class_name Country
extends RefCounted

## Represents a playable or AI-controlled nation.

signal stats_changed

var id: String = ""
var name: String = ""
var flag_code: String = ""          # ISO or custom code
var capital: String = ""
var population: float = 0.0         # in millions
var territory: float = 0.0          # km²

# Core stats
var stability: float = 50.0         # 0-100
var approval: float = 50.0          # 0-100
var ideology: float = 0.0           # -100 (left) to +100 (right)
var religion_influence: float = 30.0

# Economy component
var economy: Economy = null

# Military component
var military: Military = null

# Diplomacy component
var diplomacy: Diplomacy = null

func _init(p_id: String = "", p_name: String = "") -> void:
	id = p_id
	name = p_name
	economy = Economy.new()
	military = Military.new()
	diplomacy = Diplomacy.new()

func process_turn() -> void:
	if economy:
		economy.process_turn(self)
	if military:
		military.process_turn(self)
	if diplomacy:
		diplomacy.process_turn(self)
	
	# Natural recovery / decay
	stability = clampf(stability + randf_range(-1.5, 1.5), 0.0, 100.0)
	approval = clampf(approval + randf_range(-2.0, 2.0), 0.0, 100.0)
	
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
		"army_power": military.total_power if military else 0.0
	}
