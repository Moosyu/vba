extends CanvasLayer

const STAR_EMPTY = preload("uid://clxvuytl3xnv4")
const STAR = preload("uid://cp4ph5k08jxmn")
const BASE_LABEL = preload("res://resources/labels/base_label.tres")
const BASE_BAD_LABEL = preload("res://resources/labels/base_bad_label.tres")
const BASE_GOOD_LABEL = preload("res://resources/labels/base_good_label.tres")
const SCORE_LOWER_BOUND: float = 0.05
const PER_SCORE_VALUE: int = 200
const PER_SCORE_TIME_VALUE: int = 50

@onready var title_label: Label = $ContentContainer/VBoxContainerTop/TitleLabel
@onready var time_label: Label = $ContentContainer/VBoxContainerTop/TimeLabel
@onready var stars: Control = $ContentContainer/VBoxContainerTop/Stars
@onready var container_animator: AnimationPlayer = $ContentContainer/ContainerAnimator
@onready var score_labels: Control = $ScoreLabels

var current_time_modified: float
var score: int
var time_score: int
var typing_score: int
var drawing_score: int
var corking_score: int
var max_typing_score: Dictionary[String, Variant]
var max_drawing_score: Dictionary[String, Variant]
var max_score: int

signal stars_fallen

func _ready() -> void:
	visible = true
	container_animator.play("complete_appear")
	title_label.text = "You successfully brewed " + GameInfo.current_round_details.selected_potion.name
	time_label.text = "Time left: " + str(round(GameInfo.current_round_details.time)) + "s"
	max_typing_score = GameInfo.get_max_minigame_score(Minigame.MinigameTypes.TYPING)
	max_drawing_score = GameInfo.get_max_minigame_score(Minigame.MinigameTypes.DRAWING)

	var finished_anim: StringName = await container_animator.animation_finished
	while finished_anim != "complete_appear":
		finished_anim = await container_animator.animation_finished

	# these vlaues are kind of wack, especirally the time_score and drawing_score, probably modify calculations later
	current_time_modified = (GameInfo.current_round_details.time / GameInfo.current_round_details.selected_potion.potion_time_modification) * ((1 + ((float)(GameInfo.round_num)) / 10) / 1.5)
	time_score = round(pow(clamp(current_time_modified / GameInfo.MAX_TIME, 0.0, 1.0), 0.5) * PER_SCORE_TIME_VALUE)
	typing_score = round(clampf(float(GameInfo.typing_accuracy) / max_typing_score.get("score"), SCORE_LOWER_BOUND, 1.0) * PER_SCORE_VALUE)
	drawing_score = round(clampf(float(GameInfo.drawing_accuracy) / max_drawing_score.get("score"), SCORE_LOWER_BOUND, 1.0) * PER_SCORE_VALUE)
	corking_score = round(PER_SCORE_VALUE - clampf(GameInfo.cork_speed, 0.0, 10.0) * 20)

	# time score and corking scores are both certain to exist
	score = time_score + corking_score
	max_score = PER_SCORE_VALUE + PER_SCORE_TIME_VALUE
	
	# there isnt any ternary operator smh
	if max_drawing_score.get("valid"):
		max_score += PER_SCORE_VALUE
		score += drawing_score
	if max_typing_score.get("valid"):
		max_score += PER_SCORE_VALUE
		score += typing_score
	
	spawn_stars()
	await stars_fallen
	spawn_text()

func spawn_stars() -> void:
	var tweens: Array[Tween]
	for i in range(3):
		var star: TextureRect = TextureRect.new()
		var final_rotation_deg: float = 0.0
		var final_pos: Vector2 = Vector2(i * 135, 0)

		if score >= (max_score * 0.15) + (i * (max_score * 0.23)):
			star.texture = STAR
			GameInfo.stars_counted += 1
		else:
			star.texture = STAR_EMPTY
		star.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		star.size = Vector2(125.0, 125.0)
		star.pivot_offset = Vector2(62.5, 62.5)

		match i:
			0:
				final_rotation_deg = -10.0
			2:
				final_rotation_deg = 10.0

		star.position = final_pos - Vector2(0, 500)
		star.rotation = deg_to_rad(final_rotation_deg + randf_range(-25, 25))
		star.scale = Vector2(0.8, 0.8)
		stars.add_child(star)
		tweens.append(drop_star(0.2 * i, star, final_pos, final_rotation_deg))

	for tween: Tween in tweens:
		await tween.finished
	stars_fallen.emit()

func drop_star(delay: float, star: TextureRect, final_pos: Vector2, final_rotation_deg: float) -> Tween:
	var tween: Tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(star, "position:y", final_pos.y, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(star, "rotation", deg_to_rad(final_rotation_deg), 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(star, "scale", Vector2(1.3, 0.7), 0.06).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(star, "scale", Vector2(1.0, 1.0), 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	return tween

func spawn_text() -> void:
	var tweens: Array[Tween]
	var invalid_indicies: int = 0
	for i in range(4):
		var label = Label.new()
		label.position.y = (i - invalid_indicies) * 40
		label.self_modulate = Color(1.0, 1.0, 1.0, 0.0)
		
		match i:
			0:
				if not max_typing_score.get("valid"):
					invalid_indicies += 1
					continue
				elif typing_score >= 100:
					label.text = "+ Good typing (" + str(typing_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_GOOD_LABEL
				else:
					label.text = "- Inacurate typing (" + str(typing_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_BAD_LABEL
			1:
				if not max_drawing_score.get("valid"):
					invalid_indicies += 1
					continue
				elif drawing_score >= 100:
					label.text = "+ Good drawing (" + str(drawing_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_GOOD_LABEL
				else:
					label.text = "- Poor drawing (" + str(drawing_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_BAD_LABEL
			2:
				if corking_score >= 100:
					label.text = "+ Fast corking (" + str(corking_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_GOOD_LABEL
				else:
					label.text = "- Slow corking (" + str(corking_score) + "/" + str(PER_SCORE_VALUE) + ")"
					label.label_settings = BASE_BAD_LABEL
			3:
				if time_score >= 25:
					label.text = "+ Quick potion-making (" + str(time_score) + "/" + str(PER_SCORE_TIME_VALUE) + ")"
					label.label_settings = BASE_GOOD_LABEL
				else:
					label.text = "- Slow potion-making (" + str(time_score) + "/" + str(PER_SCORE_TIME_VALUE) + ")"
					label.label_settings = BASE_BAD_LABEL
		
		score_labels.add_child(label)
		tweens.append(display_score_label(0.4 * i, label, Vector2((score_labels.size.x - label.size.x) / 2, label.position.y)))

	for tween: Tween in tweens:
		await tween.finished
	
	GameInfo.reset_trackers()

func display_score_label(delay: float, label: Label, final_pos: Vector2) -> Tween:
	var tween = create_tween()
	tween.tween_interval(delay)
	tween.tween_property(label, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)
	tween.parallel().tween_property(label, "position", final_pos, 1.0)

	return tween

func _on_button_pressed() -> void:
	container_animator.play("complete_disappear")
	GameEvents.emit_round_transition()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "complete_disappear":
		visible = false
		GameEvents.emit_next_round()
		queue_free()
