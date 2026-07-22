extends Node2D

var holding: bool = false

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("left_click") or event is InputEventMouseMotion) and holding:
		print("attempt")
		$Potion.position = event.position
		$Potion.gravity_scale = 0.0

func _on_rigid_body_2d_mouse_entered() -> void:
	print("triggered enter")
	holding = true

func _on_rigid_body_2d_mouse_exited() -> void:
	print("triggered exit")
	holding = false
