extends Control

const MAIN_SCENE := "res://scenes/main/Main.tscn"
const MENU_SCENE := "res://scenes/ui/MainMenu.tscn"

@onready var list: ItemList = %CountryList
@onready var preview: Label = %PreviewLabel
@onready var btn_start: Button = %StartButton
@onready var btn_back: Button = %BackButton
@onready var search: LineEdit = %SearchEdit
@onready var region_row: HBoxContainer = %RegionRow

var _countries: Array = []
var _filtered: Array = []
var _selected_id: String = "AR"
var _region_filter: String = "all"

const REGIONS := ["all", "south_america", "north_america", "europe", "asia", "middle_east", "africa", "oceania"]

func _ready() -> void:
	CommandTheme.apply_to(self)
	var start_style = CommandTheme.gold_button_style()
	btn_start.add_theme_stylebox_override("normal", start_style)
	btn_start.add_theme_color_override("font_color", CommandTheme.GOLD)
	var world = WorldData.load_countries()
	_countries.clear()
	for c in world.values():
		_countries.append(c)
	_countries.sort_custom(func(a, b): return a.name < b.name)
	_filtered = _countries.duplicate()
	_build_region_buttons()
	_rebuild_list()
	list.item_selected.connect(_on_item)
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	search.text_changed.connect(_on_search)
	if _filtered.size() > 0:
		list.select(0)
		_on_item(0)

func _build_region_buttons() -> void:
	for child in region_row.get_children():
		child.queue_free()
	for r in REGIONS:
		var b = Button.new()
		b.text = r.replace("_", " ").capitalize() if r != "all" else "All"
		b.custom_minimum_size = Vector2(0, 36)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(_set_region.bind(r))
		region_row.add_child(b)
		CommandTheme._style_button(b)
		if r == _region_filter:
			b.modulate = Color(1.1, 1.0, 0.7)

func _set_region(r: String) -> void:
	_region_filter = r
	for b in region_row.get_children():
		if b is Button:
			b.modulate = Color(1.1, 1.0, 0.7) if (b as Button).text.to_lower().replace(" ", "_") == r or (r == "all" and (b as Button).text == "All") else Color.WHITE
	_apply_filters(search.text)

func _apply_filters(text: String) -> void:
	var t = text.strip_edges().to_lower()
	_filtered.clear()
	for c in _countries:
		var region_ok = _region_filter == "all" or _guess_region(c.id) == _region_filter
		var text_ok = t == "" or t in c.name.to_lower() or t in c.id.to_lower()
		if region_ok and text_ok:
			_filtered.append(c)
	_rebuild_list()

func _guess_region(id: String) -> String:
	var sa := ["AR","BR","CL","UY","PE","CO","BO","PY","VE","EC"]
	var na := ["US","CA","MX","CU","GT","HN","SV","NI","CR","PA","DO"]
	var eu := ["DE","FR","GB","IT","ES","NL","BE","SE","NO","DK","FI","PL","AT","CH","IE","PT","GR","CZ","RO","HU","SK","UA","BY"]
	var as_ := ["CN","JP","IN","KR","ID","PH","MY","TH","VN","BD","PK","TW","SG","HK","KZ"]
	var me := ["SA","TR","IL","AE","IQ","IR","SY","JO","LB","OM","BH","QA","KW","EG"]
	var af := ["ZA","NG","DZ","MA","KE","ET","GH","TZ","UG","AO","SD"]
	var oc := ["AU","NZ","PG","FJ"]
	if id in sa: return "south_america"
	if id in na: return "north_america"
	if id in eu: return "europe"
	if id in as_: return "asia"
	if id in me: return "middle_east"
	if id in af: return "africa"
	if id in oc: return "oceania"
	return "all"

func _difficulty(c: Country) -> String:
	if c.economy.gdp >= 3000: return "Easy"
	if c.economy.gdp >= 500: return "Normal"
	if c.economy.gdp >= 100: return "Hard"
	return "Very Hard"

func _rebuild_list() -> void:
	list.clear()
	for c in _filtered:
		var nuke = "☢" if c.military.has_nuclear_weapons else ""
		var diff = _difficulty(c)
		list.add_item("%s %s · GDP %.0f · Pwr %.0f · %s" % [c.name, nuke, c.economy.gdp, c.military.total_power, diff])

func _on_search(t: String) -> void:
	_apply_filters(t)

func _on_item(idx: int) -> void:
	if idx < 0 or idx >= _filtered.size():
		return
	var c: Country = _filtered[idx]
	_selected_id = c.id
	preview.text = "%s (%s)  [%s]\nPopulation: %.1f M\nGDP: %.0f B  |  Treasury: %.0f\nArmy power: %.0f\nStability: %.0f  Approval: %.0f\nNuclear: %s\nDifficulty: %s" % [
		c.name, c.id, _guess_region(c.id).replace("_", " ").capitalize(),
		c.population, c.economy.gdp, c.economy.treasury,
		c.military.total_power, c.stability, c.approval,
		"YES" if c.military.has_nuclear_weapons else "No",
		_difficulty(c)
	]

func _on_start() -> void:
	ProjectSettings.set_setting("game/start_country", _selected_id)
	get_tree().change_scene_to_file(MAIN_SCENE)
