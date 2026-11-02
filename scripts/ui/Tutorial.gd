class_name Tutorial
extends RefCounted

## Three-step onboarding for new players.

const FLAG_PATH := "user://tutorial_done.flag"

static func should_show() -> bool:
	return not FileAccess.file_exists(FLAG_PATH)

static func mark_done() -> void:
	var f = FileAccess.open(FLAG_PATH, FileAccess.WRITE)
	if f:
		f.store_string("1")
		f.close()

static func steps() -> Array:
	return [
		{
			"title": "Welcome, President",
			"body": "You lead a modern nation. Use the tabs below to manage Economy, Military, Diplomacy and Government. Your goal: survive, grow, and win by power, faith, ideology or legacy."
		},
		{
			"title": "Each turn",
			"body": "Invest, hire ministers, trade or negotiate. When ready, press Next Turn. The AI acts, events fire, and the world changes. Save often."
		},
		{
			"title": "Diplomacy & Map",
			"body": "Open Diplo to pick a target nation. Use MAP to see the world. Attack only when ready — wars cost lives and approval."
		},
	]
