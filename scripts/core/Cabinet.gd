class_name Cabinet
extends RefCounted

signal cabinet_changed

var ministers: Dictionary = {}  # Minister.Role -> Minister

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
	var pay = total_salary()
	if country.economy.treasury >= pay:
		country.economy.treasury -= pay
	else:
		for m in ministers.values():
			m.loyalty = maxf(m.loyalty - 8.0, 0.0)
	var interior = skill_of(Minister.Role.INTERIOR)
	country.stability = minf(country.stability + (interior - 1.0) * 1.5, 100.0)
	var culture = skill_of(Minister.Role.CULTURE)
	country.approval = minf(country.approval + (culture - 1.0) * 1.2, 100.0)

static func generate_candidates() -> Array:
	var names_m = ["Elena Vargas", "Marcus Chen", "Aisha Okonkwo", "Viktor Petrov", "Sofia Almeida",
		"James Okafor", "Yuki Tanaka", "Omar Hassan", "Clara Dubois", "Raj Patel",
		"Nina Kowalski", "Diego Morales", "Fatima Al-Rashid", "Lars Bergstrom", "Mei Lin",
		"Amara Diallo", "Henrik Solberg", "Priya Sharma", "Carlos Mendes", "Hana Suzuki"]
	var roles = [
		Minister.Role.ECONOMY, Minister.Role.DEFENSE, Minister.Role.FOREIGN,
		Minister.Role.INTERIOR, Minister.Role.SCIENCE, Minister.Role.CULTURE, Minister.Role.JUSTICE
	]
	var out: Array = []
	var i := 0
	for r in roles:
		var m = Minister.new("cand_%d" % i, names_m[i % names_m.size()], r, randf_range(0.9, 2.4))
		out.append(m)
		i += 1
	for j in range(6):
		var r = roles[randi() % roles.size()]
		var m = Minister.new("cand_x%d" % j, names_m[randi() % names_m.size()], r, randf_range(0.7, 2.7))
		out.append(m)
	return out

func list_hired() -> Array:
	var a: Array = []
	for m in ministers.values():
		a.append(m)
	return a
