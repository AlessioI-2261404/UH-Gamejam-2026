extends CanvasLayer
class_name HUD

enum ToolSelected {
	PENCIL,
	ERASE,
	NONE
}

signal tool_changed(tool: ToolSelected)

var toolSelected: ToolSelected = ToolSelected.NONE

func stop_animation() -> void:
	$Pencil/AnimatedSprite2D.play("100%")
	$Erase/AnimatedSprite2D.play("idle")

func tool_select(tool: ToolSelected) -> void:
	if toolSelected == tool:
		toolSelected = ToolSelected.NONE
	else:
		toolSelected = tool

	stop_animation()
	$Cursor.set_tool(toolSelected)
	tool_changed.emit(toolSelected)

func _on_pencil_btn_pressed() -> void:
	tool_select(ToolSelected.PENCIL)
	if toolSelected == ToolSelected.PENCIL:
		print("PENCIL")

func _on_erase_btn_pressed() -> void:
	tool_select(ToolSelected.ERASE)
	if toolSelected == ToolSelected.ERASE:
		print("ERASE")
