extends CanvasLayer
signal pencilSelected
enum ToolSelected {
	PENCIL,
	ERASE,
	NONE
}	

# Global Script variables
var toolSelected = ToolSelected.NONE

# Stop pencil and erase animation
func stop_animation() -> void:
	$Pencil/AnimatedSprite2D.play("idle")
	$Erase/AnimatedSprite2D.play("idle")


func tool_select(tool: ToolSelected) -> void:
	if (toolSelected == tool):
		toolSelected = ToolSelected.NONE
		print("NONE")
	else:
		toolSelected = tool
	stop_animation()


func _on_pencil_btn_pressed() -> void:
	tool_select(ToolSelected.PENCIL)
	
	# Play animation
	if (toolSelected == ToolSelected.PENCIL):
		pencilSelected.emit()
		print("PENCIL")
		pass


func _on_erase_btn_pressed() -> void:
	tool_select(ToolSelected.ERASE)
	
	# Play animation
	if (toolSelected == ToolSelected.ERASE):
		print("ERASE")
		pass
