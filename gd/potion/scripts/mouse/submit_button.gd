extends Button

func _ready() -> void:
	disabled = true

func _on_sigil_canvas_drawn_on() -> void:
	disabled = false

func _on_pressed() -> void:
	disabled = true
