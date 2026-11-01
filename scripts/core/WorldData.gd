class_name WorldData
extends RefCounted

## Loads the full country database from data/countries.json

const DATA_PATH := "res://data/countries.json"

static func load_countries() -> Dictionary:
	var countries: Dictionary = {}
	if not FileAccess.file_exists(DATA_PATH):
		push_error("WorldData: missing %s" % DATA_PATH)
		return countries
	
	var file = FileAccess.open(DATA_PATH, FileAccess.READ)
	if not file:
		push_error("WorldData: cannot open countries.json")
		return countries
	
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("WorldData: invalid JSON")
		return countries
	
	var list: Array = parsed.get("countries", [])
	for entry in list:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var id: String = str(entry.get("id", ""))
		if id == "":
			continue
		var c = _from_entry(entry)
		countries[id] = c
	
	print("[WorldData] Loaded %d countries" % countries.size())
	return countries

static func _from_entry(e: Dictionary) -> Country:
	var c = Country.new(str(e.get("id", "")), str(e.get("name", "Unknown")))
	c.population = float(e.get("pop", 10))
	c.territory = float(e.get("area", 100000))
	c.economy.gdp = float(e.get("gdp", 50))
	c.economy.treasury = float(e.get("treasury", 10))
	c.military.infantry = int(e.get("inf", 20))
	c.military.tanks = int(e.get("tanks", 2))
	c.military.aircraft = int(e.get("air", 2))
	c.military.navy = int(e.get("navy", 0))
	c.stability = float(e.get("stab", 50))
	c.approval = float(e.get("appr", 50))
	
	if bool(e.get("nuke", false)):
		c.military.has_nuclear_weapons = true
		c.military.nuclear_progress = 100.0
	
	if e.has("agri"):
		c.economy.agriculture_level = float(e.get("agri", 1.0))
	if e.has("farms"):
		c.economy.farms = int(e.get("farms", 3))
	
	# Scale starting resources roughly with population/gdp
	var scale = clampf(c.population / 50.0, 0.4, 3.0)
	c.economy.food = 80.0 * scale
	c.economy.oil = 40.0 * scale
	c.economy.iron = 35.0 * scale
	c.economy.uranium = 3.0 + (5.0 if c.military.has_nuclear_weapons else 0.0)
	
	# Industry baseline from GDP
	if c.economy.gdp > 2000:
		c.economy.industry_level = 1.8
		c.economy.science_level = 1.6
	elif c.economy.gdp > 500:
		c.economy.industry_level = 1.3
		c.economy.science_level = 1.2
	elif c.economy.gdp > 100:
		c.economy.industry_level = 1.1
	
	c.military._recalculate_power()
	return c

static func get_region_bonus(a_id: String, b_id: String, countries: Dictionary) -> float:
	# Soft regional affinity if both exist (we store region only in JSON; approximate via id groups)
	var sa := ["AR","BR","CL","UY","PE","CO","BO","PY","VE","EC","GY","SR"]
	var na := ["US","CA","MX","CU","GT","HN","SV","NI","CR","PA","DO","JM","TT"]
	var eu := ["DE","FR","GB","IT","ES","NL","BE","SE","NO","DK","FI","PL","AT","CH","IE","PT","GR","CZ","RO","HU","SK","UA","BY","RS","BG","HR","SI","LT","LV","EE","IS","LU","MT","CY","AL","MK","BA","ME","MD"]
	var as_ := ["CN","JP","IN","KR","ID","PH","MY","TH","VN","BD","PK","TW","KP","MM","LK","NP","AF","UZ","AZ","GE","AM","MN","KH","LA","BN","MV","BT","TL","SG","HK","KZ"]
	var me := ["SA","TR","IL","AE","IQ","IR","SY","JO","LB","OM","BH","QA","KW","EG"]
	var af := ["ZA","NG","DZ","MA","KE","ET","GH","TZ","UG","AO","SD","TN","LY","SN","CI","CM","ZW","ZM","MW","MG","MZ","BW","NA"]
	var oc := ["AU","NZ","PG","FJ"]
	
	for group in [sa, na, eu, as_, me, af, oc]:
		if a_id in group and b_id in group:
			return 25.0
	return 0.0
