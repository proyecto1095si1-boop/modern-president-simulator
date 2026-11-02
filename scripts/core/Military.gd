class_name Military
extends RefCounted

signal military_updated

var infantry: int = 50
var tanks: int = 10
var aircraft: int = 5
var navy: int = 3
var special_forces: int = 2

var training_level: float = 1.0
var nuclear_progress: float = 0.0
var has_nuclear_weapons: bool = false
var defense_level: float = 1.0

var total_power: float = 0.0
var maintenance_cost: float = 0.0

func _init() -> void:
	_recalculate_power()

func process_turn(country: Country) -> void:
	_recalculate_power()
	maintenance_cost = (infantry * 0.05 + tanks * 0.4 + aircraft * 0.7 + navy * 1.0 + special_forces * 0.3) * training_level
	if country.economy.treasury >= maintenance_cost:
		country.economy.treasury -= maintenance_cost
	else:
		training_level = maxf(training_level - 0.05, 0.5)
		infantry = maxi(infantry - 2, 10)
	if nuclear_progress > 0.0 and nuclear_progress < 100.0:
		nuclear_progress = minf(nuclear_progress + 1.2 + country.economy.science_level * 0.3, 100.0)
		if nuclear_progress >= 100.0:
			has_nuclear_weapons = true
	military_updated.emit()

func recruit_infantry(amount: int, economy: Economy) -> bool:
	var cost = amount * 0.7
	if economy.treasury < cost or amount <= 0:
		return false
	economy.treasury -= cost
	infantry += amount
	_recalculate_power()
	military_updated.emit()
	return true

func recruit_tanks(amount: int, economy: Economy) -> bool:
	var cost = amount * 4.5
	if economy.treasury < cost or amount <= 0 or economy.iron < amount * 2.0:
		return false
	economy.treasury -= cost
	economy.iron -= amount * 2.0
	tanks += amount
	_recalculate_power()
	military_updated.emit()
	return true

func recruit_aircraft(amount: int, economy: Economy) -> bool:
	var cost = amount * 8.0
	if economy.treasury < cost or amount <= 0:
		return false
	economy.treasury -= cost
	aircraft += amount
	_recalculate_power()
	military_updated.emit()
	return true

func recruit_navy(amount: int, economy: Economy) -> bool:
	var cost = amount * 12.0
	if economy.treasury < cost or amount <= 0:
		return false
	economy.treasury -= cost
	navy += amount
	_recalculate_power()
	military_updated.emit()
	return true

func recruit_special(amount: int, economy: Economy) -> bool:
	var cost = amount * 5.0
	if economy.treasury < cost or amount <= 0:
		return false
	economy.treasury -= cost
	special_forces += amount
	_recalculate_power()
	military_updated.emit()
	return true

func train_army(amount: float, economy: Economy) -> bool:
	var cost = amount * 4.5
	if economy.treasury < cost:
		return false
	economy.treasury -= cost
	training_level = minf(training_level + amount * 0.12, 3.5)
	_recalculate_power()
	military_updated.emit()
	return true

func invest_nuclear(amount: float, economy: Economy) -> bool:
	if economy.treasury < amount or amount <= 0:
		return false
	economy.treasury -= amount
	nuclear_progress = minf(nuclear_progress + amount * 0.35 + economy.science_level * 0.1, 100.0)
	if nuclear_progress >= 100.0:
		has_nuclear_weapons = true
	military_updated.emit()
	return true

func improve_defense(amount: float, economy: Economy) -> bool:
	if economy.treasury < amount:
		return false
	economy.treasury -= amount
	defense_level = minf(defense_level + amount * 0.08, 3.0)
	military_updated.emit()
	return true

func _recalculate_power() -> void:
	var base = infantry * 1.0 + tanks * 8.5 + aircraft * 13.0 + navy * 16.0 + special_forces * 6.0
	total_power = base * training_level * (0.7 + defense_level * 0.3)
	if has_nuclear_weapons:
		total_power *= 1.9
