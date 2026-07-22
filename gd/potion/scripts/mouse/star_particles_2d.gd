extends CPUParticles2D

func _ready() -> void:
	GameEvents.display_stars.connect(_on_display_stars)

func _on_display_stars() -> void:
	position = get_global_mouse_position()
	emitting = true
