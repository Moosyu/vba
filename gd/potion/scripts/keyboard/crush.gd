extends Node2D

const INITIAL_POSITION: Vector2 = Vector2(0.0, -15.0)

var increment_stage: int = 0
var original_y_scale: float
var current_ingredient: Ingredient = GameInfo.get_current_ingredient()

func _ready() -> void:
	$Ingredient.texture = current_ingredient.initial_state
	original_y_scale = $Ingredient.scale.y
	GameEvents.increment_mechanical_stage.connect(_on_game_event_increment)
	update_bottom_anchor()

func _on_game_event_increment(shrink: bool) -> void:
	if shrink:
		$CrushAudioPlayer.play()
		increment_stage += 1
		if increment_stage >= 4:
			$Ingredient.scale.y = original_y_scale
			$Ingredient.texture = current_ingredient.final_state
		else:
			$Ingredient.scale.y -= 0.2
		update_bottom_anchor()

	var tween: Tween = create_tween()
	tween.tween_property($Pestle, "position", Vector2(INITIAL_POSITION.x, $Ingredient.position.y - ($Ingredient.get_rect().size.y / 2)), 0.1)
	tween.tween_property($Pestle, "position", Vector2(INITIAL_POSITION), 0.1)

func update_bottom_anchor() -> void:
	if $Ingredient.texture == null:
		print("something has gone horribly wrong, was no final stage texture set?")
		return

	$Ingredient.offset.y = ((115.0 - $Ingredient.position.y) / $Ingredient.scale.y) - ($Ingredient.texture.get_size().y * 0.5)
