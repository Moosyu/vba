extends Button

const SCENE: PackedScene = preload("res://scenes/main_game.tscn")

func _on_pressed() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_packed(SCENE)
