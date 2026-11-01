class_name MapController
extends Control

## Structured world map: markers by region, pan, select target / play as nation.

signal country_clicked(country_id: String)
signal close_requested

const COORDS_PATH := "res://data/map_coords.json"

var game_manager: GameManager = null
var _coords: Dictionary = {}   # id -> Vector2 normalized
var _map_w: float = 2000.0
var _map_h: float = 1100.0
var _markers: Dictionary = {}  # id -> Button
var _selected_id: String = ""

@onready var scroll: ScrollContainer = $Scroll
@onready var canvas: Control = $Scroll/Canvas
@onready var ocean: ColorRect = $Scroll/Canvas/Ocean
@onready var markers_root: Control = $Scroll/Canvas/Markers
@onready var info_label: Label = $TopBar/InfoLabel
@onready var region_label: Label = $TopBar/RegionLabel
@onready var btn_close: Button = $TopBar/CloseButton
@onready var btn_set_target: Button = $BottomBar/SetTargetButton
@onready var btn_play_as: Button = $BottomBar/PlayAsButton
@onready var legend: Label = $BottomBar/LegendLabel

func setup(gm: GameManager) -> void:
	game_manager = gm
	_load_coords()
	_build_map()
	_refresh_colors()
	if game_manager.player_country:
		info_label.text = "You: %s" % game_manager.player_country.name

func _ready() -> void:
	btn_close.pressed.connect(func(): close_requested.emit())
	btn_set_target.pressed.connect(_on_set_target)
	btn_play_as.pressed.connect(_on_play_as)
	if game_manager:
		_load_coords()
		_build_map()
		_refresh_colors()

func _load_coords() -> void:
	_coords.clear()
	if not FileAccess.file_exists(COORDS_PATH):
		push_error("MapController: missing map_coords.json")
		return
	var file = FileAccess.open(COORDS_PATH, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if typeof(data) != TYPE_DICTIONARY:
		return
	var size: Dictionary = data.get("map_size", {})
	_map_w = float(size.get("w", 2000))
	_map_h = float(size.get("h", 1100))
	var countries: Dictionary = data.get("countries", {})
	for id in countries.keys():
		var p: Dictionary = countries[id]
		_coords[id] = Vector2(float(p.get("x", 0.5)), float(p.get("y", 0.5)))

func _build_map() -> void:
	for child in markers_root.get_children():
		child.queue_free()
	_markers.clear()
	
	canvas.custom_minimum_size = Vector2(_map_w, _map_h)
	ocean.size = Vector2(_map_w, _map_h)
	markers_root.size = Vector2(_map_w, _map_h)
	
	# Soft continent blocks (visual structure, not accurate polygons)
	_draw_region_block(0.08, 0.22, 0.28, 0.40, Color(0.15, 0.28, 0.18, 0.35), "N.America")
	_draw_region_block(0.18, 0.55, 0.22, 0.35, Color(0.18, 0.30, 0.16, 0.35), "S.America")
	_draw_region_block(0.42, 0.18, 0.22, 0.32, Color(0.20, 0.26, 0.18, 0.35), "Europe")
	_draw_region_block(0.40, 0.48, 0.28, 0.40, Color(0.22, 0.28, 0.14, 0.30), "Africa")
	_draw_region_block(0.62, 0.28, 0.32, 0.45, Color(0.22, 0.24, 0.16, 0.32), "Asia")
	_draw_region_block(0.82, 0.70, 0.16, 0.22, Color(0.20, 0.26, 0.18, 0.30), "Oceania")
	
	if not game_manager:
		return
	
	for id in game_manager.countries.keys():
		var pos_n: Vector2 = _coords.get(id, Vector2(0.5, 0.5))
		var px = pos_n.x * _map_w
		var py = pos_n.y * _map_h
		var c: Country = game_manager.countries[id]
		var btn = Button.new()
		btn.text = id
		btn.tooltip_text = "%s\nGDP %.0f | Power %.0f" % [c.name, c.economy.gdp, c.military.total_power]
		btn.custom_minimum_size = Vector2(36, 28)
		btn.position = Vector2(px - 18, py - 14)
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(_on_marker_pressed.bind(id))
		markers_root.add_child(btn)
		_markers[id] = btn
	
	region_label.text = "Map: %d markers | pan to explore" % _markers.size()

func _draw_region_block(nx: float, ny: float, nw: float, nh: float, col: Color, _name: String) -> void:
	var r = ColorRect.new()
	r.color = col
	r.position = Vector2(nx * _map_w, ny * _map_h)
	r.size = Vector2(nw * _map_w, nh * _map_h)
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ocean.add_child(r)

func _on_marker_pressed(id: String) -> void:
	_selected_id = id
	country_clicked.emit(id)
	_refresh_colors()
	if not game_manager or not game_manager.countries.has(id):
		return
	var c: Country = game_manager.countries[id]
	var rel = "—"
	if game_manager.player_country and id != game_manager.player_country.id:
		rel = game_manager.player_country.diplomacy.get_status_text(id)
	info_label.text = "%s | GDP %.0f | Army %.0f | %s" % [c.name, c.economy.gdp, c.military.total_power, rel]

func _refresh_colors() -> void:
	if not game_manager:
		return
	var player_id = game_manager.player_country.id if game_manager.player_country else ""
	var target_id = game_manager.selected_target_id
	for id in _markers.keys():
		var btn: Button = _markers[id]
		var style = StyleBoxFlat.new()
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		var c: Country = game_manager.countries[id]
		if id == player_id:
			style.bg_color = Color(0.15, 0.55, 0.95, 1)  # you
		elif id == target_id or id == _selected_id:
			style.bg_color = Color(0.95, 0.75, 0.15, 1)  # selected/target
		elif player_id != "" and id in game_manager.player_country.diplomacy.at_war_with:
			style.bg_color = Color(0.85, 0.2, 0.2, 1)  # war
		elif player_id != "" and id in game_manager.player_country.diplomacy.alliances:
			style.bg_color = Color(0.2, 0.75, 0.35, 1)  # ally
		elif c.military.has_nuclear_weapons:
			style.bg_color = Color(0.55, 0.35, 0.75, 1)  # nuclear
		else:
			style.bg_color = Color(0.25, 0.32, 0.40, 1)
		btn.add_theme_stylebox_override("normal", style)
		var hover = style.duplicate()
		hover.bg_color = style.bg_color.lightened(0.15)
		btn.add_theme_stylebox_override("hover", hover)
		btn.add_theme_stylebox_override("pressed", hover)

func _on_set_target() -> void:
	if _selected_id == "" or not game_manager:
		return
	if game_manager.player_country and _selected_id == game_manager.player_country.id:
		info_label.text = "Cannot target yourself"
		return
	game_manager.set_target(_selected_id)
	_refresh_colors()
	info_label.text = "Target set: %s" % game_manager.countries[_selected_id].name

func _on_play_as() -> void:
	if _selected_id == "" or not game_manager:
		return
	game_manager.select_country(_selected_id)
	_refresh_colors()
	info_label.text = "Now playing as: %s" % game_manager.player_country.name

func refresh() -> void:
	_refresh_colors()
	if game_manager and game_manager.player_country:
		info_label.text = "You: %s" % game_manager.player_country.name
