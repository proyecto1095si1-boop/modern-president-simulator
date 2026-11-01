class_name Diplomacy
extends RefCounted

## Handles relations with other countries, alliances, sanctions, etc.

signal diplomacy_updated

# Relations: country_id -> value (-100 to +100)
var relations: Dictionary = {}

var alliances: Array[String] = []
var at_war_with: Array[String] = []
var embargos: Array[String] = []

func process_turn(_country: Country) -> void:
	# Natural drift of relations toward 0
	for id in relations.keys():
		var val = relations[id]
		if val > 0:
			relations[id] = maxf(val - 0.3, 0.0)
		elif val < 0:
			relations[id] = minf(val + 0.3, 0.0)
	
	diplomacy_updated.emit()

func get_relation(country_id: String) -> float:
	return relations.get(country_id, 0.0)

func set_relation(country_id: String, value: float) -> void:
	relations[country_id] = clampf(value, -100.0, 100.0)
	diplomacy_updated.emit()

func improve_relation(country_id: String, amount: float = 5.0) -> void:
	var current = get_relation(country_id)
	set_relation(country_id, current + amount)

func worsen_relation(country_id: String, amount: float = 5.0) -> void:
	var current = get_relation(country_id)
	set_relation(country_id, current - amount)

func form_alliance(country_id: String) -> bool:
	if country_id in alliances:
		return false
	if get_relation(country_id) < 40.0:
		return false   # need good relations
	alliances.append(country_id)
	improve_relation(country_id, 15.0)
	return true

func declare_war(country_id: String) -> void:
	if country_id not in at_war_with:
		at_war_with.append(country_id)
	worsen_relation(country_id, 80.0)
	if country_id in alliances:
		alliances.erase(country_id)
