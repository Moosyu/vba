extends Control

func start_animation(type_text: String) -> void:
	var target_rotation: float = randf_range(-10, 10)
	var tween: Tween = create_tween()
	tween.tween_property($TypeLabel, "rotation", deg_to_rad(target_rotation), 0.45).set_ease(Tween.EASE_OUT)
	$TypeLabel.text = type_text
	$AnimationPlayer.play("text_spawn_animation")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "text_spawn_animation":
		queue_free()
