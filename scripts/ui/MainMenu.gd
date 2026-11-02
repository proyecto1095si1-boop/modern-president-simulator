extends Control

const MAIN_SCENE := "res://scenes/main/Main.tscn"
const SELECT_SCENE := "res://scenes/ui/CountrySelect.tscn"

@onready var title_label: Label = %TitleLabel
@onready var subtitle: Label = %SubtitleLabel
@onready var btn_new: Button = %NewGameButton
@onready var btn_continue: Button = %ContinueButton
@onready var btn_quit: Button = %QuitButton
@onready var version_label: Label = %VersionLabel

func _ready() -> void:
	btn_new.pressed.connect(_on_new)
	btn_continue.pressed.connect(_on_continue)
	btn_quit.pressed.connect(_on_quit)
	btn_continue.disabled = not FileAccess.file_exists("user://savegame.json")
	version_label.text = "v0.7 · ~70% playable loop"
	var tw = create_tween().set_loops()
	tw.tween_property(title_label, "modulate", Color(1.1, 1.05, 0.9), 1.4)
	tw.tween_property(title_label, "modulate", Color.WHITE, 1.4)

func _on_new() -> void:
	ProjectSettings.set_setting("game/load_on_start", false)
	get_tree().change_scene_to_file(SELECT_SCENE)

func _on_continue() -> void:
	ProjectSettings.set_setting("game/load_on_start", true)
	get_tree().change_scene_to_file(MAIN_SCENE)

func _on_quit() -> void:
	get_tree().quit()
