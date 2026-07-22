extends Label

func _ready() -> void:
	var start_pos: Vector2 = position
	var x_offset: float = randf_range(-50.0, 20.0)
	
	start_pos.x += x_offset
	position = start_pos
	
	var target_pos: Vector2 = start_pos + Vector2(0, -20)
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func show_result(result_text: String) -> void:
	text = result_text
	$ResultAnimationPlayer.play("result_label")

func _on_result_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "result_label":
		queue_free()
