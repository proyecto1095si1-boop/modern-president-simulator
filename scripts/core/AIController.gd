class_name AIController
extends RefCounted

## AI per non-player country each turn.

static func process_country(country: Country, all_countries: Dictionary, player: Country) -> void:
	if not country or (player and country.id == player.id):
		return
	
	var eco = country.economy
	var mil = country.military
	var dev = country.development
	
	# Economic growth
	if eco.treasury > 35.0:
		var roll = randf()
		if roll < 0.28:
			eco.invest_industry(8.0)
		elif roll < 0.45:
			eco.invest_agriculture(6.0)
		elif roll < 0.58:
			eco.invest_energy(7.0)
		elif roll < 0.70 and eco.treasury > 50.0:
			mil.recruit_infantry(6 + int(eco.gdp / 500.0), eco)
		elif roll < 0.80 and eco.treasury > 70.0:
			mil.train_army(0.5, eco)
		elif roll < 0.90 and dev:
			var sectors = ["education", "infrastructure", "science", "culture", "justice"]
			dev.invest(sectors[randi() % sectors.size()], 8.0, eco)
	
	# Nuclear for major powers
	if eco.gdp > 1200.0 and not mil.has_nuclear_weapons and eco.treasury > 90.0 and randf() < 0.10:
		mil.invest_nuclear(18.0, eco)
	
	# Diplomacy vs player
	if player and randf() < 0.18:
		var rel = country.diplomacy.get_relation(player.id)
		if rel > 35.0 and randf() < 0.45:
			country.diplomacy.improve_relation(player.id, randf_range(2.0, 7.0))
		elif rel < -25.0 and randf() < 0.35:
			country.diplomacy.worsen_relation(player.id, randf_range(3.0, 8.0))
		# Rare AI aggression against weak player
		if rel < -50.0 and mil.total_power > player.military.total_power * 1.4 and randf() < 0.08:
			if player.id not in country.diplomacy.at_war_with:
				country.diplomacy.declare_war(player.id)
				player.diplomacy.declare_war(country.id)
	
	# AI vs AI mild rivalry (keeps world alive)
	if randf() < 0.06 and all_countries.size() > 5:
		var keys = all_countries.keys()
		var other_id = keys[randi() % keys.size()]
		if other_id != country.id and (not player or other_id != player.id):
			if randf() < 0.5:
				country.diplomacy.improve_relation(other_id, randf_range(1.0, 4.0))
			else:
				country.diplomacy.worsen_relation(other_id, randf_range(1.0, 5.0))
