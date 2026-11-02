class_name Achievements
extends RefCounted

## Lightweight mid-game goals to improve session pacing.

signal unlocked(id: String, title: String)

var unlocked_ids: Array[String] = []

func check(player: Country, turn: int) -> void:
	if not player:
		return
	_try("first_minister", "Cabinet formed", player.cabinet.ministers.size() >= 1)
	_try("full_cabinet", "Full cabinet", player.cabinet.ministers.size() >= 7)
	_try("industrial", "Industrial power", player.economy.industry_level >= 2.0)
	_try("nuclear_ready", "Nuclear capable", player.military.has_nuclear_weapons)
	_try("rich", "Fat treasury", player.economy.treasury >= 200.0)
	_try("popular", "Beloved leader", player.approval >= 80.0)
	_try("stable", "Rock solid", player.stability >= 85.0)
	_try("veteran", "20 turns in office", turn >= 20)
	_try("devoted", "Faith rising", player.development.religion_influence >= 60.0)
	_try("ideologue", "Society model", player.development.ideology_score >= 70.0)

func _try(id: String, title: String, condition: bool) -> void:
	if condition and id not in unlocked_ids:
		unlocked_ids.append(id)
		unlocked.emit(id, title)

func list_unlocked() -> Array[String]:
	return unlocked_ids.duplicate()
