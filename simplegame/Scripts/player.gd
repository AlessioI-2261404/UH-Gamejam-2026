extends CharacterBody2D

@export var tile_size: int = 32
@export var move_time: float = 0.12

var _moving := false
var _from_pos: Vector2
var _to_pos: Vector2
var _t := 0.0

func _ready() -> void:
	add_to_group("player")
	# Snap player to grid on start
	global_position = global_position.snapped(Vector2(tile_size, tile_size))

func _physics_process(delta: float) -> void:
	if _moving:
		_t += delta / move_time
		global_position = _from_pos.lerp(_to_pos, clamp(_t, 0.0, 1.0))
		if _t >= 1.0:
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

	# Use CharacterBody2D collision check: test move without actually moving.
	# We create a motion vector to the target and see if it collides.
	var motion := target - global_position

	# test_move checks collisions for the given transform/motion.
	if test_move(global_transform, motion):
		return # blocked

	_from_pos = global_position
	_to_pos = target
	_t = 0.0
	_moving = true
