class_name Minister
extends RefCounted

## A cabinet minister with specialization and skill.

enum Role {
	ECONOMY,
	DEFENSE,
	FOREIGN,
	INTERIOR,
	SCIENCE,
	CULTURE,
	JUSTICE
}

var id: String = ""
var display_name: String = ""
var role: Role = Role.ECONOMY
var skill: float = 1.0          # 0.5 - 3.0
var loyalty: float = 70.0       # 0-100
var salary: float = 2.0         # per turn from treasury
var portrait_style: String = "suit"  # visual tag

func _init(p_id: String = "", p_name: String = "", p_role: Role = Role.ECONOMY, p_skill: float = 1.0) -> void:
	id = p_id
	display_name = p_name
	role = p_role
	skill = clampf(p_skill, 0.5, 3.0)
	salary = 1.5 + skill * 0.8

func role_name() -> String:
	match role:
		Role.ECONOMY: return "Economy"
		Role.DEFENSE: return "Defense"
		Role.FOREIGN: return "Foreign Affairs"
		Role.INTERIOR: return "Interior"
		Role.SCIENCE: return "Science"
		Role.CULTURE: return "Culture"
		Role.JUSTICE: return "Justice"
	return "Minister"

func bonus_description() -> String:
	match role:
		Role.ECONOMY: return "+%.0f%% tax efficiency, industry growth" % (skill * 8.0)
		Role.DEFENSE: return "+%.0f%% training, lower maintenance" % (skill * 6.0)
		Role.FOREIGN: return "+%.0f relation gains from diplomacy" % (skill * 5.0)
		Role.INTERIOR: return "+%.0f stability recovery / turn" % (skill * 2.0)
		Role.SCIENCE: return "+%.0f%% science & nuclear research" % (skill * 10.0)
		Role.CULTURE: return "+%.0f approval soft power" % (skill * 3.0)
		Role.JUSTICE: return "Lower scandal impact, +stability" % []
	return ""


class_name Cabinet
extends RefCounted

signal cabinet_changed

var ministers: Dictionary = {}  # Role -> Minister

func hire(minister: Minister) -> bool:
	if ministers.has(minister.role):
		return false
	ministers[minister.role] = minister
	cabinet_changed.emit()
	return true

func fire(role: Minister.Role) -> void:
	if ministers.has(role):
		ministers.erase(role)
		cabinet_changed.emit()

func get_minister(role: Minister.Role) -> Minister:
	return ministers.get(role, null)

func has_role(role: Minister.Role) -> bool:
	return ministers.has(role)

func total_salary() -> float:
	var s := 0.0
	for m in ministers.values():
		s += m.salary
	return s

func skill_of(role: Minister.Role) -> float:
	var m = get_minister(role)
	return m.skill if m else 1.0

func process_turn(country: Country) -> void:
	# Pay salaries
	var pay = total_salary()
	if country.economy.treasury >= pay:
		country.economy.treasury -= pay
	else:
		# Unpaid ministers lose loyalty
		for m in ministers.values():
			m.loyalty = maxf(m.loyalty - 8.0, 0.0)
	
	# Apply soft bonuses
	var interior = skill_of(Minister.Role.INTERIOR)
	country.stability = minf(country.stability + (interior - 1.0) * 1.5, 100.0)
	var culture = skill_of(Minister.Role.CULTURE)
	country.approval = minf(country.approval + (culture - 1.0) * 1.2, 100.0)

static func generate_candidates(rng_seed: int = 0) -> Array:
	var names_m = ["Elena Vargas", "Marcus Chen", "Aisha Okonkwo", "Viktor Petrov", "Sofia Almeida",
		"James Okafor", "Yuki Tanaka", "Omar Hassan", "Clara Dubois", "Raj Patel",
		"Nina Kowalski", "Diego Morales", "Fatima Al-Rashid", "Lars Bergstrom", "Mei Lin"]
	var roles = [
		Minister.Role.ECONOMY, Minister.Role.DEFENSE, Minister.Role.FOREIGN,
		Minister.Role.INTERIOR, Minister.Role.SCIENCE, Minister.Role.CULTURE, Minister.Role.JUSTICE
	]
	var out: Array = []
	var i := 0
	for r in roles:
		var skill = randf_range(0.9, 2.4)
		var n = names_m[i % names_m.size()]
		var m = Minister.new("cand_%d" % i, n, r, skill)
		out.append(m)
		i += 1
	# Extra randoms
	for j in range(5):
		var r = roles[randi() % roles.size()]
		var m = Minister.new("cand_x%d" % j, names_m[randi() % names_m.size()], r, randf_range(0.7, 2.6))
		out.append(m)
	return out
