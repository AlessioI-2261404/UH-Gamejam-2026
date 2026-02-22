extends CanvasLayer
class_name HUD

enum ToolSelected {
	PENCIL,
	ERASE,
	NONE
}

var pencil_power: float = 500.0
var _last_pencil_state: int = 0

signal tool_changed(tool: ToolSelected)
var toolSelected: ToolSelected = ToolSelected.NONE

signal move_pressed()
signal clear_path()



func stop_animation() -> void:
	$Pencil/AnimatedSprite2D.play(["100%", "75%", "50%", "25%", "0%"][_last_pencil_state])
	$Erase/AnimatedSprite2D.play("idle")

func tool_select(tool: ToolSelected) -> void:
	if toolSelected == tool:
		toolSelected = ToolSelected.NONE
		set_tool(ToolSelected.NONE)
	else:
		toolSelected = tool
		set_tool(tool)

	tool_changed.emit(toolSelected)


func update_pencil_state(state: int) -> void:
	
	if _last_pencil_state > state:
		print("YES")
		return
	
	if _last_pencil_state == 4 and state == 4:
		tool_select(ToolSelected.NONE)	
		return
	
	_last_pencil_state = state  
	var anim: String = ["100%", "75%", "50%", "25%", "0%"][state]

	$Pencil/AnimatedSprite2D.play(anim)
	$Cursor.set_pencil_cursor(state)

	
	
	
func set_tool(tool: ToolSelected) -> void:
	toolSelected = tool
	stop_animation()
	match tool:
		ToolSelected.PENCIL:
			if _last_pencil_state != 4:
				$Cursor.set_pencil_cursor(_last_pencil_state)  # restore, not reset
		ToolSelected.ERASE:
			$Cursor.set_eraser_cursor()
		ToolSelected.NONE:
			$Cursor.set_default_cursor()

	
func _on_pencil_btn_pressed() -> void:
	tool_select(ToolSelected.PENCIL)
	if toolSelected == ToolSelected.PENCIL:
		print("PENCIL")

func _on_erase_btn_pressed() -> void:
	tool_select(ToolSelected.ERASE)
	if toolSelected == ToolSelected.ERASE:
		print("ERASE")

func _on_reset_button_pressed() -> void:
	_last_pencil_state = 0
	var anim: String = ["100%", "75%", "50%", "25%", "0%"][_last_pencil_state]
	tool_select(ToolSelected.NONE)
	clear_path.emit()

func _on_move_button_pressed() -> void:
	if _last_pencil_state == 4:
		print("I CAN MOVE?")
		move_pressed.emit()
