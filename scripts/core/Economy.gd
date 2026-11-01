class_name Economy
extends RefCounted

## Handles national economy: production, taxes, treasury, resources, investments.

signal economy_updated

var gdp: float = 100.0                  # billion USD equivalent
var treasury: float = 50.0              # current money
var tax_rate: float = 0.25              # 0.05 - 0.55
var debt: float = 0.0
var inflation: float = 2.0              # %

# Resources
var food: float = 100.0
var oil: float = 50.0
var iron: float = 40.0
var uranium: float = 5.0
var gold: float = 20.0

# Production levels (buildings / tech)
var industry_level: float = 1.0
var agriculture_level: float = 1.0
var energy_level: float = 1.0
var science_level: float = 1.0

# Buildings count (simplified)
var factories: int = 2
var farms: int = 3
var power_plants: int = 1
var mines: int = 1

func process_turn(country: Country) -> void:
	# Tax income
	var tax_income = gdp * tax_rate * 0.12
	treasury += tax_income
	
	# Production from buildings + levels
	food += (farms * 4.0 + agriculture_level * 6.0)
	oil += (power_plants * 2.0 + energy_level * 2.5)
	iron += (mines * 2.0 + industry_level * 2.0)
	uranium += mines * 0.15 * science_level
	gold += industry_level * 0.8
	
	# Consumption based on population
	var pop = country.population
	food = maxf(food - pop * 0.75, 0.0)
	oil = maxf(oil - pop * 0.12, 0.0)
	
	# Penalties if critical resources run out
	if food < 10.0:
		country.stability = maxf(country.stability - 3.0, 0.0)
		country.approval = maxf(country.approval - 4.0, 0.0)
	if oil < 5.0:
		gdp = maxf(gdp - 2.0, 5.0)
	
	# GDP growth
	var growth = 0.25 + (country.stability - 50.0) * 0.008
	growth += (industry_level - 1.0) * 0.4
	growth += (science_level - 1.0) * 0.25
	growth -= inflation * 0.05
	gdp = maxf(gdp + growth, 5.0)
	
	# Inflation pressure from high taxes / low stability
	if tax_rate > 0.35:
		inflation += 0.15
	else:
		inflation = maxf(inflation - 0.08, 0.5)
	
	# Debt interest
	if debt > 0.0:
		var interest = debt * 0.006
		treasury -= interest
		debt += interest * 0.25
	
	economy_updated.emit()

func take_loan(amount: float) -> bool:
	if amount <= 0.0 or amount > gdp * 0.4:
		return false
	treasury += amount
	debt += amount * 1.12
	economy_updated.emit()
	return true

func repay_debt(amount: float) -> bool:
	if amount <= 0.0 or treasury < amount:
		return false
	var pay = minf(amount, debt)
	treasury -= pay
	debt -= pay
	economy_updated.emit()
	return true

func set_tax_rate(rate: float) -> void:
	tax_rate = clampf(rate, 0.05, 0.55)
	economy_updated.emit()

func invest_industry(amount: float) -> bool:
	if treasury < amount:
		return false
	treasury -= amount
	industry_level += amount * 0.025
	factories += 1 if amount >= 15.0 else 0
	economy_updated.emit()
	return true

func invest_agriculture(amount: float) -> bool:
	if treasury < amount:
		return false
	treasury -= amount
	agriculture_level += amount * 0.03
	farms += 1 if amount >= 10.0 else 0
	economy_updated.emit()
	return true

func invest_energy(amount: float) -> bool:
	if treasury < amount:
		return false
	treasury -= amount
	energy_level += amount * 0.028
	power_plants += 1 if amount >= 12.0 else 0
	economy_updated.emit()
	return true

func invest_science(amount: float) -> bool:
	if treasury < amount:
		return false
	treasury -= amount
	science_level += amount * 0.02
	economy_updated.emit()
	return true
