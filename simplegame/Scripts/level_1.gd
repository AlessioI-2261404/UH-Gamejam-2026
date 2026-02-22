extends Node2D
@export_file("*.tscn") var next_scene: String

@onready var ground_layer = $Ground
@onready var highlight_layer = $Path_Highlight
@onready var hud: HUD = $HUD
@onready var player = $Player
@onready var drawing_layer = $Drawer  # add this at the top
#@onready var box = $Box


var drawing := false
var current_tool: HUD.ToolSelected = HUD.ToolSelected.NONE
var path: Array[Vector2i] = []
var mouse_on_player : bool = false

# --- highlight tile info (adjust to your highlight tileset) ---
const HIGHLIGHT_SOURCE_ID: int = 0
const HIGHLIGHT_ATLAS_COORDS: Vector2i = Vector2i(0, 0)
# -------------------------------------------------------------

# If you want to restrict drawing only where there is a ground tile:
@export var restrict_to_ground_tiles: bool = false

func _ready() -> void:
	hud.tool_changed.connect(_on_tool_changed)
	hud.move_pressed.connect(_move_player)
	hud.clear_path.connect(_clear_drawer_path)
	drawing_layer.path.append(player.global_position)

	


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
		else:
			hud.stop_pencil_sound()
			hud.stop_eraser_sound()

	# Dragging
	if event is InputEventMouseMotion:
		if drawing:
			_apply_tool_from_mouse()
		else:
			# Still update the dot even when not clicking
			var world_pos: Vector2 = get_global_mouse_position()
			mouse_on_player = world_pos.distance_to(player.global_position) < 32.0
			drawing_layer.dot_pos = world_pos
			hud.stop_eraser_sound()
			hud.stop_pencil_sound()

	
	if not drawing:
		drawing_layer.queue_redraw()
		hud.stop_eraser_sound()
		hud.stop_pencil_sound()

func _apply_tool_from_mouse() -> void:
	var world_pos: Vector2 = get_global_mouse_position()
	mouse_on_player = world_pos.distance_to(player.global_position) < 50.0
	print(world_pos)
	# Update the dot layer
	
	
	if current_tool == HUD.ToolSelected.PENCIL:
		var cell: Vector2i = ground_layer.local_to_map(ground_layer.to_local(world_pos))
		if ground_layer.get_cell_source_id(cell) == -1:
			return

		# Cast a line from last point to new point
		if drawing_layer.path.size() > 0:
			var last_pos: Vector2 = drawing_layer.path.back()
			var space_state = get_world_2d().direct_space_state
			var params = PhysicsRayQueryParameters2D.create(last_pos, world_pos)
			params.exclude = [player.get_rid()]
			var result = space_state.intersect_ray(params)
			if result:
				return  # line crosses an obstacle

		drawing_layer.dot_pos = world_pos
		drawing_layer.queue_redraw()
		drawing_layer.path.append(world_pos)
		
		# Update both pencil sprites
		var state: int = drawing_layer._calc_pencil_state(hud.pencil_power)
		hud.update_pencil_state(state)
		hud.play_pencil_sound()
	
	if current_tool == HUD.ToolSelected.ERASE:
		var erase_radius: float = 50.0
		var first = drawing_layer.path[0]  # keep player start position
		drawing_layer.path = drawing_layer.path.filter(
			func(p): return p == first or p.distance_to(world_pos) > erase_radius
		)
		drawing_layer.queue_redraw()
		hud.play_eraser_sound()
		
		
func _move_player() -> void:
	player.playAnimation("moving")
	player.playWalkingSound(true)
	for dot in drawing_layer.path:
		player.adjust_position(dot)
		await player.reached_position 
	player.playWalkingSound(false)
	player.playAnimation("idle")

		
func _clear_drawer_path() -> void:
	var first: Vector2 = drawing_layer.path[0]
	#box.global_position = $BoxStartPos.global_position
	drawing_layer.path.clear()
	drawing_layer.path.append(first)
	drawing_layer.queue_redraw()
	
	player.playAnimation("moving")
	player.adjust_position(player.original_position)
	player.playAnimation("idle")

	

func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("PLAYER EXIT")
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			hud._on_reset_button_pressed()
			get_tree().change_scene_to_file("res://levels/Level2.tscn")
