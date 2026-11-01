class_name Economy
extends RefCounted

## Handles national economy: production, taxes, treasury, resources.

signal economy_updated

var gdp: float = 100.0                  # billion USD equivalent
var treasury: float = 50.0              # current money
var tax_rate: float = 0.25              # 0.0 - 0.6
var debt: float = 0.0
var inflation: float = 2.0              # %

# Resources (simplified)
var food: float = 100.0
var oil: float = 50.0
var iron: float = 40.0
var uranium: float = 5.0
var gold: float = 20.0

# Production modifiers
var industry_level: float = 1.0
var agriculture_level: float = 1.0
var energy_level: float = 1.0

func process_turn(country: Country) -> void:
	# Tax income
	var tax_income = gdp * tax_rate * 0.15   # monthly-ish factor
	treasury += tax_income
	
	# Production
	food += agriculture_level * 8.0
	oil += energy_level * 3.0
	iron += industry_level * 2.5
	
	# Consumption based on population
	var pop = country.population
	food -= pop * 0.8
	oil -= pop * 0.15
	
	# Clamp resources
	food = maxf(food, 0.0)
	oil = maxf(oil, 0.0)
	iron = maxf(iron, 0.0)
	
	# GDP growth influenced by stability and industry
	var growth = 0.3 + (country.stability - 50.0) * 0.01 + (industry_level - 1.0) * 0.5
	gdp += growth
	gdp = maxf(gdp, 5.0)
	
	# Debt interest
	if debt > 0:
		var interest = debt * 0.005
		treasury -= interest
		debt += interest * 0.3
	
	economy_updated.emit()

func take_loan(amount: float) -> bool:
	if amount <= 0:
		return false
	treasury += amount
	debt += amount * 1.1   # with interest premium
	return true

func set_tax_rate(rate: float) -> void:
	tax_rate = clampf(rate, 0.05, 0.55)
	economy_updated.emit()

func invest_industry(amount: float) -> bool:
	if treasury < amount:
		return false
	treasury -= amount
	industry_level += amount * 0.02
	return true
