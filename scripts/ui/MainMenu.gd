extends Control

const MAIN_SCENE := "res://scenes/main/Main.tscn"
const SELECT_SCENE := "res://scenes/ui/CountrySelect.tscn"

@onready var title_label: Label = %TitleLabel
@onready var subtitle: Label = %SubtitleLabel
@onready var btn_new: Button = %NewGameButton
@onready var btn_continue: Button = %ContinueButton
@onready var btn_quit: Button = %QuitButton
@onready var version_label: Label = %VersionLabel
@onready var tagline: Label = %TaglineLabel

func _ready() -> void:
	CommandTheme.apply_to(self)
	_style_primary(btn_new)
	btn_new.pressed.connect(_on_new)
	btn_continue.pressed.connect(_on_continue)
	btn_quit.pressed.connect(_on_quit)
	btn_continue.disabled = not FileAccess.file_exists("user://savegame.json")
	version_label.text = "v0.9.1 · Command Aesthetic"
	var tw = create_tween().set_loops()
	tw.tween_property(title_label, "modulate", Color(1.15, 1.05, 0.75), 1.6)
	tw.tween_property(title_label, "modulate", Color(0.95, 0.88, 0.55), 1.6)

func _style_primary(b: Button) -> void:
	var s = CommandTheme.gold_button_style()
	b.add_theme_stylebox_override("normal", s)
	var h = s.duplicate() as StyleBoxFlat
	h.bg_color = Color(0.45, 0.36, 0.12)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_color_override("font_color", CommandTheme.GOLD)

func _on_new() -> void:
	ProjectSettings.set_setting("game/load_on_start", false)
	get_tree().change_scene_to_file(SELECT_SCENE)

func _on_continue() -> void:
	ProjectSettings.set_setting("game/load_on_start", true)
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_quit() -> void:
	get_tree().quit()
