class_name GameManager
extends Node

## Central controller of the simulation.
## Manages the list of countries, current player, and turn progression.

signal turn_started(turn: int)
signal turn_ended(turn: int)
signal player_stats_updated

var current_turn: int = 1
var player_country: Country = null
var countries: Dictionary = {}   # id -> Country

func _ready() -> void:
	_create_sample_world()
	print("[GameManager] World created with %d countries" % countries.size())
	print("[GameManager] You are leading: %s" % player_country.name)

func _create_sample_world() -> void:
	# Player country - Argentina as example (easy to change later)
	var argentina = Country.new("AR", "Argentina")
	argentina.population = 46.0
	argentina.territory = 2780000.0
	argentina.economy.gdp = 640.0
	argentina.economy.treasury = 80.0
	argentina.military.infantry = 70
	argentina.military.tanks = 15
	argentina.stability = 55.0
	argentina.approval = 48.0
	
	countries["AR"] = argentina
	player_country = argentina
	
	# A few AI countries for testing
	var brazil = Country.new("BR", "Brazil")
	brazil.population = 215.0
	brazil.economy.gdp = 2100.0
	brazil.military.infantry = 180
	brazil.military.tanks = 40
	countries["BR"] = brazil
	
	var chile = Country.new("CL", "Chile")
	chile.population = 19.5
	chile.economy.gdp = 320.0
	chile.military.infantry = 45
	countries["CL"] = chile
	
	var usa = Country.new("US", "United States")
	usa.population = 335.0
	usa.economy.gdp = 27000.0
	usa.military.infantry = 450
	usa.military.tanks = 200
	usa.military.aircraft = 120
	usa.military.has_nuclear_weapons = true
	countries["US"] = usa
	
	# Initial relations
	player_country.diplomacy.set_relation("BR", 35.0)
	player_country.diplomacy.set_relation("CL", 55.0)
	player_country.diplomacy.set_relation("US", 25.0)

func next_turn() -> void:
	print("\n========== TURN %d ==========" % current_turn)
	
	# Process all countries
	for country in countries.values():
		country.process_turn()
	
	current_turn += 1
	turn_ended.emit(current_turn - 1)
	turn_started.emit(current_turn)
	player_stats_updated.emit()
	
	_print_player_status()

func _print_player_status() -> void:
	var c = player_country
	print("Country: %s | Turn: %d" % [c.name, current_turn])
	print("  Population: %.1f M | Stability: %.1f | Approval: %.1f" % [c.population, c.stability, c.approval])
	print("  GDP: %.1f | Treasury: %.1f | Tax: %.0f%%" % [c.economy.gdp, c.economy.treasury, c.economy.tax_rate * 100])
	print("  Army Power: %.0f | Nuclear: %s" % [c.military.total_power, str(c.military.has_nuclear_weapons)])
	print("  Resources → Food: %.0f | Oil: %.0f | Iron: %.0f" % [c.economy.food, c.economy.oil, c.economy.iron])
