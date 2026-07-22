extends CanvasLayer

@onready var cork_sprite: Sprite2D = $Cork/CorkSprite
@onready var potion_liquid: Sprite2D = $Potion/PotionLiquid
@onready var cork: RigidBody2D = $Cork

func _ready() -> void:
	GameEvents.round_transition.connect(_on_round_transition)
	GameEvents.setting_updated.connect(on_setting_updated)

	$InstructionLabel.text = "Drag the cork into the potion's slot [color=#9f46e8]rightside up[/color].\nScroll to rotate the cork."
	$InstructionLabel.visible = Settings.show_tutorials

func _on_round_transition() -> void:
	var tween = create_tween()
	var potion_liquid_material: ShaderMaterial = potion_liquid.material
	var selected_potion_color: Color = GameInfo.current_round_details.selected_potion.potion_color

	tween.tween_property(potion_liquid_material, "shader_parameter/potion_color", Color(selected_potion_color.r, selected_potion_color.g, selected_potion_color.b, 0.0), 0.1)
	$PotionPlayer.play("potion_fade_out")

func _on_place_cork() -> void:
	$InstructionLabel.text = "Double click the cork to seal the potion."

func on_setting_updated() -> void:
	$InstructionLabel.visible = Settings.show_tutorials
