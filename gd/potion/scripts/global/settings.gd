extends Node

const SAVE_PATH = "user://settings.cfg"

var show_tutorials: bool = true:
	set(value):
		show_tutorials = value
		save_settings()

var show_guidelines: bool = true:
	set(value):
		show_guidelines = value
		save_settings()

var music_volume: float = 1.0:
	set(value):
		music_volume = value
		save_settings()

func _ready() -> void:
	load_settings()

func save_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	config.set_value("gameplay", "show_tutorials", show_tutorials)
	config.set_value("gameplay", "show_guidelines", show_guidelines)
	config.set_value("audio", "music_volume", music_volume)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config: ConfigFile = ConfigFile.new()
	
	if config.load(SAVE_PATH) != Error.OK:
		return
	
	show_tutorials = config.get_value("gameplay", "show_tutorials", true)
	show_guidelines = config.get_value("gameplay", "show_guidelines", true)
	music_volume = config.get_value("audio", "music_volume", 1.0)
