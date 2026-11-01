class_name AIController
extends RefCounted

## Very simple AI that runs once per turn for non-player countries.
## Focus: grow economy a bit, recruit if rich, random diplomatic noise.

static func process_country(country: Country, all_countries: Dictionary, player: Country) -> void:
	if not country or (player and country.id == player.id):
		return
	
	var eco = country.economy
	var mil = country.military
	
	# Prefer investment if treasury is healthy
	if eco.treasury > 40.0:
		var roll = randf()
		if roll < 0.35:
			eco.invest_industry(8.0)
		elif roll < 0.55:
			eco.invest_agriculture(6.0)
		elif roll < 0.70:
			eco.invest_energy(7.0)
		elif roll < 0.85 and eco.treasury > 60.0:
			mil.recruit_infantry(8, eco)
		elif eco.treasury > 80.0:
			mil.train_army(0.6, eco)
	
	# Occasional nuclear push for large powers
	if eco.gdp > 1500.0 and not mil.has_nuclear_weapons and eco.treasury > 100.0 and randf() < 0.12:
		mil.invest_nuclear(20.0, eco)
	
	# Soft diplomacy toward player
	if player and randf() < 0.15:
		var rel = country.diplomacy.get_relation(player.id)
		if rel > 30.0 and randf() < 0.4:
			country.diplomacy.improve_relation(player.id, randf_range(2.0, 6.0))
		elif rel < -20.0 and randf() < 0.3:
			country.diplomacy.worsen_relation(player.id, randf_range(2.0, 5.0))
