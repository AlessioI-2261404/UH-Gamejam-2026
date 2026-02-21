extends CharacterBody2D

@export var tile_size: int = 256
@export var move_time: float = 0.6

var _moving := false
var _from_pos: Vector2
var _to_pos: Vector2
var _t := 0.0

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if _moving:
		$AnimatedSprite2D.play("moving")
		_t += delta / move_time
		global_position = _from_pos.lerp(_to_pos, clamp(_t, 0.0, 1.0))
		if _t >= 1.0:
			$AnimatedSprite2D.play("idle")
			global_position = _to_pos
			_moving = false
		return

	var dir := Vector2.ZERO
	if Input.is_action_just_pressed("ui_right"):
		dir = Vector2.RIGHT
	elif Input.is_action_just_pressed("ui_left"):
		dir = Vector2.LEFT
	elif Input.is_action_just_pressed("ui_up"):
		dir = Vector2.UP
	elif Input.is_action_just_pressed("ui_down"):
		dir = Vector2.DOWN

	if dir != Vector2.ZERO:
		_try_move(dir)

func _try_move(dir: Vector2) -> void:
	var target := global_position + dir * tile_size
	var motion := target - global_position

	if test_move(global_transform, motion):
		return # blocked

	_from_pos = global_position
	_to_pos = target
	_t = 0.0
	_moving = true
