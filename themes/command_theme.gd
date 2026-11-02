class_name CommandTheme
extends RefCounted

## Builds a cohesive dark-command Theme for the whole game.

const BG := Color(0.04, 0.06, 0.10)
const PANEL := Color(0.08, 0.11, 0.16)
const PANEL_EDGE := Color(0.18, 0.24, 0.32)
const GOLD := Color(0.85, 0.70, 0.28)
const GOLD_DIM := Color(0.65, 0.55, 0.25)
const TEXT := Color(0.92, 0.94, 0.96)
const TEXT_DIM := Color(0.55, 0.60, 0.68)
const ACCENT := Color(0.25, 0.55, 0.85)
const DANGER := Color(0.85, 0.32, 0.28)
const SUCCESS := Color(0.30, 0.75, 0.48)

static func apply_to(root: Control) -> void:
	root.add_theme_color_override("font_color", TEXT)
	_style_buttons_recursive(root)

static func _style_buttons_recursive(node: Node) -> void:
	if node is Button:
		_style_button(node as Button)
	elif node is Label:
		var l := node as Label
		if not l.has_theme_color_override("font_color"):
			l.add_theme_color_override("font_color", TEXT)
	for c in node.get_children():
		_style_buttons_recursive(c)

static func _style_button(b: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = PANEL
	normal.border_color = PANEL_EDGE
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(6)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.12, 0.16, 0.22)
	hover.border_color = GOLD_DIM
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.14, 0.18, 0.26)
	pressed.border_color = GOLD
	b.add_theme_stylebox_override("normal", normal)
	b.add_theme_stylebox_override("hover", hover)
	b.add_theme_stylebox_override("pressed", pressed)
	b.add_theme_stylebox_override("focus", hover)
	if not b.has_theme_color_override("font_color"):
		b.add_theme_color_override("font_color", TEXT)
	b.add_theme_color_override("font_hover_color", GOLD)
	b.add_theme_color_override("font_pressed_color", GOLD)

static func panel_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = PANEL
	s.border_color = PANEL_EDGE
	s.set_border_width_all(1)
	s.set_corner_radius_all(8)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s

static func gold_button_style() -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = Color(0.35, 0.28, 0.10)
	s.border_color = GOLD
	s.set_border_width_all(1)
	s.set_corner_radius_all(6)
	s.content_margin_left = 12
	s.content_margin_right = 12
	s.content_margin_top = 10
	s.content_margin_bottom = 10
	return s
