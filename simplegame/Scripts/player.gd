# In player.gd
extends CharacterBody2D
signal reached_position

var target: Vector2
var original_position: Vector2
var speed: float = 1000.0

func adjust_position(dot: Vector2) -> void:
	target = dot

func _ready() -> void:
	original_position = global_position
	target = global_position

func _process(delta: float) -> void:
	if global_position.distance_to(target) > 2.0:
		global_position = global_position.move_toward(target, speed * delta)
	else:
		global_position = target
		reached_position.emit()

func playAnimation(type : String):
	$AnimatedSprite2D.play(type)

func playWalkingSound(play : bool = true):
	if play:
		$walkingsound.play()	
	else:
		$walkingsound.stop()
		
