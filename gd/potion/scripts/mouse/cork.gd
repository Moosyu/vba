extends RigidBody2D

const ROTATE_AMOUNT: float = deg_to_rad(10.0)
const MAX_DRAG_SPEED: float = 1500.0
const DRAG_LINEAR_DAMP: float = 8.0
const CORK_FINAL_POSITION: Vector2 = Vector2(572.0, 200.0)

var grabbed: bool = false
var mouse_over_cork: bool = false
var prev_safe_mouse_pos: Vector2
var target_position: Vector2
var target_rotation: float = 0.0
var pending_lock: bool = false
var final_lock: bool = false
var time_elapsed: float = 0.0
var stopwatch_stopped: bool = false

signal place_cork

func _ready() -> void:
	# feels less harsh than CCD_MODE_CAST_SHAPE (and is supposedly faster), check up on this
	# again later
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	rotation = randf_range(-90, 90)

func _process(delta: float) -> void:
	if not stopwatch_stopped and not GameInfo.game_paused:
		time_elapsed += delta

func _physics_process(delta: float) -> void:
	if grabbed and not freeze:
		var mouse_pos: Vector2 = get_global_mouse_position()
		if get_viewport_rect().has_point(mouse_pos):
			prev_safe_mouse_pos = mouse_pos

		var to_target: Vector2 = prev_safe_mouse_pos - global_position
		var desired_velocity: Vector2 = to_target / delta
		
		linear_velocity = desired_velocity.limit_length(MAX_DRAG_SPEED)
		linear_damp = DRAG_LINEAR_DAMP
		rotation = lerp_angle(rotation, target_rotation, delta * 15)
	else:
		linear_damp = 0.0

	if final_lock:
		global_position = lerp(global_position, target_position, 0.3)

func _on_mouse_entered() -> void:
	mouse_over_cork = true
	Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)

func _on_mouse_exited() -> void:
	mouse_over_cork = false
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)

func _input(event: InputEvent) -> void:
	if GameInfo.game_paused:
		return
	
	if Input.is_action_pressed("left_click"):
		if mouse_over_cork:
			if not grabbed:
				target_rotation = rotation
			grabbed = true
	else:
		grabbed = false

	if grabbed:
		if event.is_action_pressed("scroll_up"):
			target_rotation -= ROTATE_AMOUNT
		elif event.is_action_pressed("scroll_down"):
			target_rotation += ROTATE_AMOUNT

	if event is InputEventMouseButton:
		if freeze and event.double_click and not final_lock:
			final_lock = true
			target_position = Vector2(position.x, position.y + 20)
			GameEvents.emit_display_stars()
			stopwatch_stopped = true
			GameInfo.cork_speed = time_elapsed
			await get_tree().create_timer(1.0).timeout
			GameEvents.emit_minigame_complete_attempt(true)

func _on_potion_opening_body_entered(body: Node2D) -> void:
	if body == self:
		pending_lock = true
		place_cork.emit()

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if pending_lock:
		state.transform.origin = CORK_FINAL_POSITION
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		pending_lock = false
		call_deferred("_finish_lock")

func _finish_lock() -> void:
	freeze = true
	global_position = CORK_FINAL_POSITION
	global_rotation = 0
