extends Control

const MAIN_SCENE := "res://scenes/main/Main.tscn"
const MENU_SCENE := "res://scenes/ui/MainMenu.tscn"

@onready var list: ItemList = %CountryList
@onready var preview: Label = %PreviewLabel
@onready var btn_start: Button = %StartButton
@onready var btn_back: Button = %BackButton
@onready var search: LineEdit = %SearchEdit

var _countries: Array = []
var _filtered: Array = []
var _selected_id: String = "AR"

func _ready() -> void:
	var world = WorldData.load_countries()
	_countries.clear()
	for c in world.values():
		_countries.append(c)
	_countries.sort_custom(func(a, b): return a.name < b.name)
	_filtered = _countries.duplicate()
	_rebuild_list()
	list.item_selected.connect(_on_item)
	btn_start.pressed.connect(_on_start)
	btn_back.pressed.connect(func(): get_tree().change_scene_to_file(MENU_SCENE))
	search.text_changed.connect(_on_search)
	if _filtered.size() > 0:
		list.select(0)
		_on_item(0)

func _rebuild_list() -> void:
	list.clear()
	for c in _filtered:
		var nuke = " ☢" if c.military.has_nuclear_weapons else ""
		list.add_item("%s%s  ·  GDP %.0f  ·  Power %.0f" % [c.name, nuke, c.economy.gdp, c.military.total_power])

func _on_search(t: String) -> void:
	t = t.strip_edges().to_lower()
	_filtered.clear()
	for c in _countries:
		if t == "" or t in c.name.to_lower() or t in c.id.to_lower():
			_filtered.append(c)
	_rebuild_list()

func _on_item(idx: int) -> void:
	if idx < 0 or idx >= _filtered.size():
		return
	var c: Country = _filtered[idx]
	_selected_id = c.id
	preview.text = "%s (%s)\nPopulation: %.1f M\nGDP: %.0f B  |  Treasury: %.0f\nArmy power: %.0f\nStability: %.0f  Approval: %.0f\nNuclear: %s" % [
		c.name, c.id, c.population, c.economy.gdp, c.economy.treasury,
		c.military.total_power, c.stability, c.approval,
		"YES" if c.military.has_nuclear_weapons else "No"
	]

func _on_start() -> void:
	# Store choice for Main to pick up
	ProjectSettings.set_setting("game/start_country", _selected_id)
	get_tree().change_scene_to_file(MAIN_SCENE)
