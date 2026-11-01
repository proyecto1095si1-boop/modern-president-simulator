class_name Military
extends RefCounted

## Manages army, training, nuclear program and basic combat power.

signal military_updated

var infantry: int = 50
var tanks: int = 10
var aircraft: int = 5
var navy: int = 3

var training_level: float = 1.0       # 0.5 - 3.0
var nuclear_progress: float = 0.0     # 0-100
var has_nuclear_weapons: bool = false

var total_power: float = 0.0

func _init() -> void:
	_recalculate_power()

func process_turn(country: Country) -> void:
	# Maintenance cost is handled in Economy later
	_recalculate_power()
	
	# Slow nuclear research if funded
	if nuclear_progress > 0 and nuclear_progress < 100:
		nuclear_progress = minf(nuclear_progress + 1.5, 100.0)
		if nuclear_progress >= 100.0:
			has_nuclear_weapons = true
	
	military_updated.emit()

func recruit_infantry(amount: int, economy: Economy) -> bool:
	var cost = amount * 0.8
	if economy.treasury < cost:
		return false
	economy.treasury -= cost
	infantry += amount
	_recalculate_power()
	return true

func train_army(amount: float, economy: Economy) -> bool:
	var cost = amount * 5.0
	if economy.treasury < cost:
		return false
	economy.treasury -= cost
	training_level = minf(training_level + amount * 0.1, 3.0)
	_recalculate_power()
	return true

func invest_nuclear(amount: float, economy: Economy) -> bool:
	if economy.treasury < amount:
		return false
	economy.treasury -= amount
	nuclear_progress = minf(nuclear_progress + amount * 0.4, 100.0)
	return true

func _recalculate_power() -> void:
	total_power = (infantry * 1.0 + tanks * 8.0 + aircraft * 12.0 + navy * 15.0) * training_level
	if has_nuclear_weapons:
		total_power *= 1.8
