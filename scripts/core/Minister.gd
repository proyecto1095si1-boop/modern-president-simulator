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
var skill: float = 1.0
var loyalty: float = 70.0
var salary: float = 2.0
var portrait_style: String = "suit"

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
		Role.ECONOMY: return "+%.0f%% tax efficiency & industry" % (skill * 8.0)
		Role.DEFENSE: return "+%.0f%% training, lower upkeep" % (skill * 6.0)
		Role.FOREIGN: return "+%.0f diplomacy relation gains" % (skill * 5.0)
		Role.INTERIOR: return "+%.0f stability / turn" % (skill * 2.0)
		Role.SCIENCE: return "+%.0f%% science & nuclear" % (skill * 10.0)
		Role.CULTURE: return "+%.0f approval soft power" % (skill * 3.0)
		Role.JUSTICE: return "Lower scandal impact, +stability"
	return ""
