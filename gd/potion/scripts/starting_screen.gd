extends CanvasLayer

const OPTIONS = preload("res://scenes/options.tscn")

func _on_options_button_pressed() -> void:
	add_child(OPTIONS.instantiate())
