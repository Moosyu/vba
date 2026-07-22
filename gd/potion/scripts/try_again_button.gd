extends Button

func _on_pressed() -> void:
	GameInfo.reset_values()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
