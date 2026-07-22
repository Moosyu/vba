extends Node2D

const SLICE_DURATION: float = 0.35
const FLING_DISTANCE: float = 45.0
# in radians
const FLING_ROTATION: float = 0.45

var cut: int = 0

func _ready() -> void:
	GameEvents.increment_mechanical_stage.connect(_increment_mechanical_stage)
	$Ingredient.texture = GameInfo.get_current_ingredient().initial_state

func _increment_mechanical_stage(_change_stage: bool) -> void:
	$SliceStreamPlayer.play()
	slice_and_advance_stage()

func slice_and_advance_stage() -> void:
	create_slice_pieces()

	$Ingredient.visible = false
	# this is null on the transition to the next stage
	get_tree().create_timer(SLICE_DURATION + 0.05).timeout.connect(func(): $Ingredient.visible = true)

func create_slice_pieces() -> void:
	var texture_size: Vector2 = $Ingredient.texture.get_size()
	var split_x: float = texture_size.x * randf_range(0.35, 0.65)
	
	# left piece
	animate_piece(make_piece(Rect2(Vector2.ZERO, Vector2(split_x, texture_size.y))), Vector2(-FLING_DISTANCE, FLING_DISTANCE * 0.4), -FLING_ROTATION)
	# right piece
	animate_piece(make_piece(Rect2(Vector2(split_x, 0.0), Vector2(texture_size.x - split_x, texture_size.y))), Vector2(FLING_DISTANCE, FLING_DISTANCE * 0.4), FLING_ROTATION)

func make_piece(region: Rect2) -> Sprite2D:
	var piece: Sprite2D = Sprite2D.new()
	piece.texture = $Ingredient.texture
	piece.region_enabled = true
	piece.region_rect = region
	piece.centered = false
	piece.scale = $Ingredient.scale
	piece.z_index = $Ingredient.z_index + 1
	piece.z_as_relative = $Ingredient.z_as_relative

	var top_left: Vector2
	if $Ingredient.centered:
		top_left = $Ingredient.position - ($Ingredient.texture.get_size() * 0.5) * $Ingredient.scale
	else:
		top_left = $Ingredient.position

	add_child(piece)
	piece.position = top_left + region.position * $Ingredient.scale
	piece.global_rotation = $Ingredient.global_rotation

	return piece

func animate_piece(piece: Sprite2D, offset: Vector2, piece_rotation: float) -> void:
	var tween: Tween = create_tween()

	tween.set_parallel(true)
	tween.tween_property(piece, "position", piece.position + offset, SLICE_DURATION)
	tween.tween_property(piece, "rotation", piece_rotation, SLICE_DURATION)
	tween.tween_property(piece, "modulate:a", 0.0, SLICE_DURATION * 0.7).set_delay(SLICE_DURATION * 0.3)
	tween.chain().tween_callback(piece.queue_free)
