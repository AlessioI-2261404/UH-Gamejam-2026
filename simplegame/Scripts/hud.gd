extends CanvasLayer
class_name HUD

enum ToolSelected {
	PENCIL,
	ERASE,
	NONE
}

@onready var eraser_sounds = [$Cursor/EraserSound1, $Cursor/EraserSound2, $Cursor/EraserSound3]
@onready var pencil_sounds = [$Cursor/PencilSound1, $Cursor/PencilSound2, $Cursor/PencilSound3]
var current_pencil_sound : int = 0
var current_eraser_sound : int = 0

var pencil_power: float = 3000.0 #IN PIXELS
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
		tool_changed.emit(toolSelected)
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

func set_initial_pencil_power(power : float) -> void:
	pencil_power = power
	
	
	
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
	print("I CAN MOVE?")
	move_pressed.emit()


func play_eraser_sound():
	if not eraser_sounds[current_eraser_sound].playing:
		var idx: int = randi_range(0, 2)
		current_eraser_sound = idx
		eraser_sounds[idx].play()
	
func play_pencil_sound() -> void:
	if not pencil_sounds[current_pencil_sound].playing:
		var idx: int = randi_range(0, 2)
		current_pencil_sound = idx
		pencil_sounds[idx].play()

func stop_pencil_sound() -> void:
	pencil_sounds[current_pencil_sound].stop()

func stop_eraser_sound() -> void:
	eraser_sounds[current_eraser_sound].stop()
