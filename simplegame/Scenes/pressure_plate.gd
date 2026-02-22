extends Node2D
signal activated()
signal unactivated()

var active: bool = false

func _emit_plate_status() -> void:
	if (active):
		activated.emit()
	else:
		unactivated.emit()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if (body.name != "Player"):
		active = true
		print("ghallo")
		_emit_plate_status()
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	if (body.name != "Player"):
		active = false
		print("ghallo")
		_emit_plate_status()
