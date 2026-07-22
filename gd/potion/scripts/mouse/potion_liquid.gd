extends Sprite2D

var timer: float
var last_round: bool
var round_complete
var selected_potion_color: Color

func _ready() -> void:	
	last_round = (GameInfo.round_num == GameInfo.ROUND_COUNT - 1)
	if not last_round:
		selected_potion_color = GameInfo.current_round_details.selected_potion.potion_color
		material.set_shader_parameter("potion_color", selected_potion_color)

func _process(delta: float) -> void:
	if last_round and not GameInfo.round_over:
		timer += (delta / 10)
		selected_potion_color = Color.from_hsv(fmod(timer, 1.0), 1.0, 1.0)
		material.set_shader_parameter("potion_color", selected_potion_color)
