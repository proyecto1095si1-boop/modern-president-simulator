class_name Intel
extends RefCounted

## Soft power ops: recon and sabotage against a target nation.

static func recon(actor: Country, target: Country) -> String:
	if not actor or not target:
		return "Invalid target"
	if actor.economy.treasury < 6.0:
		return "Need 6 B treasury for recon"
	if target.id in actor.diplomacy.at_war_with:
		# cheaper during war but riskier flavor only
		pass
	actor.economy.treasury -= 6.0
	var leak = randf()
	var report = "%s intel:\n  Army power ≈ %.0f\n  Treasury ≈ %.0f\n  Stability %.0f | Approval %.0f\n  Nuclear: %s" % [
		target.name,
		target.military.total_power * randf_range(0.9, 1.1),
		target.economy.treasury * randf_range(0.85, 1.15),
		target.stability,
		target.approval,
		"YES" if target.military.has_nuclear_weapons else "No"
	]
	if leak < 0.12:
		target.diplomacy.worsen_relation(actor.id, 8.0)
		report += "\n(Operation partially exposed — relations -8)"
	return report

static func sabotage(actor: Country, target: Country) -> String:
	if not actor or not target:
		return "Invalid target"
	if actor.economy.treasury < 14.0:
		return "Need 14 B for sabotage"
	if actor.diplomacy.get_relation(target.id) > 40.0:
		return "Relations too friendly — spies refuse"
	actor.economy.treasury -= 14.0
	var success = randf() < (0.45 + actor.cabinet.skill_of(Minister.Role.INTERIOR) * 0.08)
	if success:
		target.economy.gdp = maxf(target.economy.gdp - randf_range(8.0, 18.0), 5.0)
		target.stability = maxf(target.stability - randf_range(4.0, 10.0), 0.0)
		target.diplomacy.worsen_relation(actor.id, 15.0)
		actor.diplomacy.worsen_relation(target.id, 10.0)
		return "Sabotage SUCCESS on %s — GDP and stability hit" % target.name
	else:
		target.diplomacy.worsen_relation(actor.id, 25.0)
		actor.diplomacy.worsen_relation(target.id, 20.0)
		return "Sabotage FAILED on %s — agents caught, major diplomatic hit" % target.name
