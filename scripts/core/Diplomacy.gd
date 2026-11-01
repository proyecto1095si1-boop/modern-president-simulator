class_name Diplomacy
extends RefCounted

## Handles relations, alliances, wars, embargos and soft power actions.

signal diplomacy_updated

var relations: Dictionary = {}          # country_id -> -100..100
var alliances: Array[String] = []
var at_war_with: Array[String] = []
var embargos: Array[String] = []
var embassies: Array[String] = []

func process_turn(_country: Country) -> void:
	for id in relations.keys():
		var val: float = relations[id]
		if val > 0.0:
			relations[id] = maxf(val - 0.25, 0.0)
		elif val < 0.0:
			relations[id] = minf(val + 0.25, 0.0)
	diplomacy_updated.emit()

func get_relation(country_id: String) -> float:
	return float(relations.get(country_id, 0.0))

func set_relation(country_id: String, value: float) -> void:
	relations[country_id] = clampf(value, -100.0, 100.0)
	diplomacy_updated.emit()

func improve_relation(country_id: String, amount: float = 5.0) -> void:
	set_relation(country_id, get_relation(country_id) + amount)

func worsen_relation(country_id: String, amount: float = 5.0) -> void:
	set_relation(country_id, get_relation(country_id) - amount)

## Spend money to improve relations (soft power)
func send_diplomats(country_id: String, economy: Economy, cost: float = 8.0) -> bool:
	if economy.treasury < cost:
		return false
	if country_id in at_war_with:
		return false
	economy.treasury -= cost
	improve_relation(country_id, 8.0 + randf_range(0.0, 4.0))
	return true

func open_embassy(country_id: String, economy: Economy) -> bool:
	if country_id in embassies:
		return false
	if economy.treasury < 12.0:
		return false
	if get_relation(country_id) < 10.0:
		return false
	economy.treasury -= 12.0
	embassies.append(country_id)
	improve_relation(country_id, 12.0)
	return true

func form_alliance(country_id: String) -> bool:
	if country_id in alliances or country_id in at_war_with:
		return false
	if get_relation(country_id) < 45.0:
		return false
	alliances.append(country_id)
	improve_relation(country_id, 18.0)
	return true

func break_alliance(country_id: String) -> void:
	if country_id in alliances:
		alliances.erase(country_id)
		worsen_relation(country_id, 20.0)

func declare_war(country_id: String) -> void:
	if country_id not in at_war_with:
		at_war_with.append(country_id)
	worsen_relation(country_id, 80.0)
	if country_id in alliances:
		alliances.erase(country_id)
	if country_id in embassies:
		embassies.erase(country_id)

func offer_peace(country_id: String) -> bool:
	if country_id not in at_war_with:
		return false
	# Peace is easier if you are stronger or relation not completely destroyed
	at_war_with.erase(country_id)
	improve_relation(country_id, 25.0)
	return true

func impose_embargo(country_id: String) -> void:
	if country_id not in embargos:
		embargos.append(country_id)
	worsen_relation(country_id, 15.0)

func lift_embargo(country_id: String) -> void:
	if country_id in embargos:
		embargos.erase(country_id)
		improve_relation(country_id, 8.0)

func get_status_text(country_id: String) -> String:
	var rel = get_relation(country_id)
	var status = "Neutral"
	if country_id in at_war_with:
		status = "AT WAR"
	elif country_id in alliances:
		status = "Ally"
	elif rel >= 50.0:
		status = "Friendly"
	elif rel <= -40.0:
		status = "Hostile"
	return "%s (%.0f)" % [status, rel]
