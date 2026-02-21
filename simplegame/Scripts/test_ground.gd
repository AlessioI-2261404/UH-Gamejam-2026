extends Node2D

@onready var ground_layer = $Ground
@onready var highlight_layer = $Path_Highlight
@onready var hud: HUD = $HUD

var drawing := false
var current_tool: HUD.ToolSelected = HUD.ToolSelected.NONE
var path: Array[Vector2i] = []

# --- highlight tile info (adjust to your highlight tileset) ---
const HIGHLIGHT_SOURCE_ID: int = 0
const HIGHLIGHT_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
# -------------------------------------------------------------

# If you want to restrict drawing only where there is a ground tile:
@export var restrict_to_ground_tiles: bool = false

func _ready() -> void:
	hud.tool_changed.connect(_on_tool_changed)

func _on_tool_changed(tool: HUD.ToolSelected) -> void:
	current_tool = tool
	drawing = false

func _unhandled_input(event: InputEvent) -> void:
	# Only draw/erase if a tool is selected
	if current_tool == HUD.ToolSelected.NONE:
		return

	# Start/stop drawing with left mouse button
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		drawing = event.pressed
		if drawing:
			_apply_tool_from_mouse()
		return

	# Dragging
	if drawing and event is InputEventMouseMotion:
		_apply_tool_from_mouse()

func _apply_tool_from_mouse() -> void:
	var world_pos: Vector2 = get_global_mouse_position()

	# IMPORTANT: map using highlight layer so it respects its position/offset
	var cell: Vector2i = highlight_layer.local_to_map(highlight_layer.to_local(world_pos))

	# Optional restriction: only allow drawing where ground exists
	if restrict_to_ground_tiles:
		var ground_source: int = ground_layer.get_cell_source_id(cell)
		if ground_source == -1:
			return

	if current_tool == HUD.ToolSelected.PENCIL:
		_draw_cell(cell)
	elif current_tool == HUD.ToolSelected.ERASE:
		_erase_cell(cell)

func _draw_cell(cell: Vector2i) -> void:
	# Avoid duplicates in path
	if not path.has(cell):
		path.append(cell)

	# Paint highlight tile
	highlight_layer.set_cell(cell, HIGHLIGHT_SOURCE_ID, HIGHLIGHT_ATLAS_COORDS)

func _erase_cell(cell: Vector2i) -> void:
	# Remove highlight tile
	highlight_layer.erase_cell(cell)

	# Remove from path if present
	var idx := path.find(cell)
	if idx != -1:
		path.remove_at(idx)
