extends AudioStreamPlayer

const BRAIN_EMPTY = preload("res://assets/music/brain_empty.wav")
const TAPERED_OUT = preload("res://assets/music/tapered_out.wav")
const SONG_OPTIONS: Array[AudioStreamWAV] = [BRAIN_EMPTY, TAPERED_OUT]

func _ready() -> void:
	GameEvents.setting_updated.connect(_on_settings_updated)
	set_volume()
	_on_finished()

func _on_finished() -> void:
	stream = SONG_OPTIONS.pick_random()
	play()

func _on_settings_updated() -> void:
	set_volume()

func set_volume() -> void:
	volume_db = lerp(-80.0, 0.0, Settings.music_volume)
