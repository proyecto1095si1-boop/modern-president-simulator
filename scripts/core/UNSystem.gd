class_name UNSystem
extends RefCounted

## Simplified UN: propose a resolution affecting the target or global rules.

enum ResType { CONDEMN, SANCTIONS, PEACEKEEPING, NUKE_BAN }

static func propose(actor: Country, target: Country, kind: ResType, world: Dictionary) -> String:
	if not actor or not target:
		return "Invalid"
	if actor.economy.treasury < 5.0:
		return "Need 5 B to table a resolution"
	actor.economy.treasury -= 5.0
	
	var support := 0
	var oppose := 0
	for id in world.keys():
		var c: Country = world[id]
		if c.id == actor.id:
			support += 1
			continue
		if c.id == target.id:
			oppose += 1
			continue
		var rel_actor = c.diplomacy.get_relation(actor.id) if c.diplomacy else 0.0
		var rel_target = c.diplomacy.get_relation(target.id) if c.diplomacy else 0.0
		var score = rel_actor - rel_target * 0.6
		match kind:
			ResType.CONDEMN:
				score += 5.0
			ResType.SANCTIONS:
				score -= 5.0
			ResType.NUKE_BAN:
				if c.military.has_nuclear_weapons:
					score -= 20.0
				else:
					score += 8.0
			ResType.PEACEKEEPING:
				if target.id in actor.diplomacy.at_war_with:
					score += 10.0
		if score >= 0.0:
			support += 1
		else:
			oppose += 1
	
	var passed = support > oppose
	var label = _label(kind)
	if not passed:
		return "UN resolution '%s' vs %s FAILED (%d–%d)" % [label, target.name, support, oppose]
	
	# Apply effects
	match kind:
		ResType.CONDEMN:
			target.approval = maxf(target.approval - 6.0, 0.0)
			actor.diplomacy.improve_relation(target.id, -5.0)
		ResType.SANCTIONS:
			target.economy.gdp = maxf(target.economy.gdp - 15.0, 5.0)
			target.economy.treasury = maxf(target.economy.treasury - 20.0, 0.0)
			target.diplomacy.worsen_relation(actor.id, 20.0)
			if target.id not in actor.diplomacy.embargos:
				actor.diplomacy.impose_embargo(target.id)
		ResType.PEACEKEEPING:
			if target.id in actor.diplomacy.at_war_with:
				actor.diplomacy.offer_peace(target.id)
				target.diplomacy.offer_peace(actor.id)
			target.stability = minf(target.stability + 5.0, 100.0)
		ResType.NUKE_BAN:
			if not target.military.has_nuclear_weapons:
				target.military.nuclear_progress = maxf(target.military.nuclear_progress - 25.0, 0.0)
			else:
				target.approval = maxf(target.approval - 4.0, 0.0)
	
	return "UN resolution '%s' vs %s PASSED (%d–%d)" % [label, target.name, support, oppose]

static func _label(kind: ResType) -> String:
	match kind:
		ResType.CONDEMN: return "Condemn"
		ResType.SANCTIONS: return "Sanctions"
		ResType.PEACEKEEPING: return "Peacekeeping"
		ResType.NUKE_BAN: return "Nuclear freeze"
	return "Resolution"
