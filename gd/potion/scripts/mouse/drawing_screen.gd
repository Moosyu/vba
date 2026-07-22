extends CanvasLayer

var chosen_sigil: Sigil = GameInfo.get_current_minigame()
@onready var sigil_texture_rect: TextureRect = $SigilBackgroundTextureRect/SigilTextureRect

func _ready() -> void:
	GameEvents.setting_updated.connect(on_setting_updated)
	sigil_texture_rect.texture = chosen_sigil.icon
	$InstructionLabel.visible = Settings.show_tutorials

func on_setting_updated() -> void:
	$InstructionLabel.visible = Settings.show_tutorials
