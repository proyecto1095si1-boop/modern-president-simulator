class_name Battle
extends RefCounted

## Simple turn-based battle between two countries.
## Result depends on military power, training, defense and some randomness.

signal battle_finished(attacker_id: String, defender_id: String, attacker_won: bool, report: String)

static func resolve(attacker: Country, defender: Country) -> Dictionary:
	var atk_power = attacker.military.total_power
	var def_power = defender.military.total_power * (0.85 + defender.military.defense_level * 0.15)
	
	# Randomness ±15%
	atk_power *= randf_range(0.85, 1.15)
	def_power *= randf_range(0.85, 1.15)
	
	var attacker_won = atk_power > def_power
	var ratio = atk_power / maxf(def_power, 1.0)
	
	var report = ""
	var atk_loss_inf = 0
	var atk_loss_tanks = 0
	var def_loss_inf = 0
	var def_loss_tanks = 0
	
	if attacker_won:
		# Attacker wins – moderate losses, defender suffers more
		atk_loss_inf = int(attacker.military.infantry * randf_range(0.05, 0.12))
		atk_loss_tanks = int(attacker.military.tanks * randf_range(0.03, 0.10))
		def_loss_inf = int(defender.military.infantry * randf_range(0.18, 0.35))
		def_loss_tanks = int(defender.military.tanks * randf_range(0.15, 0.30))
		
		report = "%s defeated %s! (Power %.0f vs %.0f)" % [attacker.name, defender.name, atk_power, def_power]
		
		# Approval / stability effects
		attacker.approval = minf(attacker.approval + 6.0, 100.0)
		attacker.stability = minf(attacker.stability + 3.0, 100.0)
		defender.approval = maxf(defender.approval - 10.0, 0.0)
		defender.stability = maxf(defender.stability - 12.0, 0.0)
		
		# Improve relation penalty
		attacker.diplomacy.worsen_relation(defender.id, 40.0)
		defender.diplomacy.worsen_relation(attacker.id, 50.0)
	else:
		# Defender wins
		atk_loss_inf = int(attacker.military.infantry * randf_range(0.20, 0.40))
		atk_loss_tanks = int(attacker.military.tanks * randf_range(0.18, 0.35))
		def_loss_inf = int(defender.military.infantry * randf_range(0.06, 0.15))
		def_loss_tanks = int(defender.military.tanks * randf_range(0.04, 0.12))
		
		report = "%s failed to conquer %s. (Power %.0f vs %.0f)" % [attacker.name, defender.name, atk_power, def_power]
		
		attacker.approval = maxf(attacker.approval - 8.0, 0.0)
		attacker.stability = maxf(attacker.stability - 5.0, 0.0)
		defender.approval = minf(defender.approval + 7.0, 100.0)
		defender.stability = minf(defender.stability + 4.0, 100.0)
		
		attacker.diplomacy.worsen_relation(defender.id, 35.0)
		defender.diplomacy.worsen_relation(attacker.id, 25.0)
	
	# Apply losses
	attacker.military.infantry = maxi(attacker.military.infantry - atk_loss_inf, 5)
	attacker.military.tanks = maxi(attacker.military.tanks - atk_loss_tanks, 0)
	defender.military.infantry = maxi(defender.military.infantry - def_loss_inf, 5)
	defender.military.tanks = maxi(defender.military.tanks - def_loss_tanks, 0)
	
	attacker.military._recalculate_power()
	defender.military._recalculate_power()
	
	# War state
	if attacker.id not in attacker.diplomacy.at_war_with:
		attacker.diplomacy.declare_war(defender.id)
	if defender.id not in defender.diplomacy.at_war_with:
		defender.diplomacy.declare_war(attacker.id)
	
	report += " | Losses → Atk: %d inf / %d tanks | Def: %d inf / %d tanks" % [
		atk_loss_inf, atk_loss_tanks, def_loss_inf, def_loss_tanks
	]
	
	return {
		"attacker_won": attacker_won,
		"report": report,
		"atk_power": atk_power,
		"def_power": def_power,
		"ratio": ratio
	}
