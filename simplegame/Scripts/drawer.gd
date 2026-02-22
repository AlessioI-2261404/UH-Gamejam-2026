extends Node2D

var dot_pos: Vector2 = Vector2.ZERO
var path: Array[Vector2] = []  # stores all placed dots

func _draw() -> void:
	for i in range(path.size()):
		draw_circle(to_local(path[i]), 2.0, Color.WHITE)
		
		# Connect to next dot if it exists
		if i + 1 < path.size():
			draw_line(to_local(path[i]), to_local(path[i + 1]), Color.WHITE, 10.0)

func _calc_pencil_state(pencil_power: float) -> int:
	var num_dots : int = len(path)
	var normalized: float = clamp(float(num_dots) / pencil_power, 0.0, 1.0)
	return mini(int(normalized * 5), 4)


	
	
	
	
