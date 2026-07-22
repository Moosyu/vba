extends CanvasLayer

const STARTING_SCREEN = preload("res://scenes/starting_screen.tscn")

func _ready() -> void:
	$GPUParticles2D.emitting = true
	$Label.text = "You did it!\nYou got " + str(GameInfo.stars_counted) + "/" + str(GameInfo.round_num * 3) + " stars."

func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(STARTING_SCREEN)
	GameInfo.reset_values()
	GameInfo.reset_trackers()
