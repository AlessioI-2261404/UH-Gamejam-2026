extends Node2D
@export_file("*.tscn") var next_scene: String

@onready var ground_layer = $Ground
@onready var highlight_layer = $Path_Highlight
@onready var hud: HUD = $HUD
@onready var player = $Player
@onready var drawing_layer = $Drawer  # add this at the top

#pressure plate - box relations
@onready var box = $Box
@onready var gate7 = $gate7/CollisionShape2D
@onready var gateparticle = $gateparticle/CPUParticles2D
@onready var pressureplate = $PressurePlate

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
	hud.set_initial_pencil_power(6000)	
	pressureplate.activated.connect(on_pressure_plate_pressed)
	pressureplate.unactivated.connect(on_pressure_plate_exited)


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
			params.exclude = [player.get_rid(), box.get_rid()]
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
	while drawing_layer.path.size() > 1:
		var dot: Vector2 = drawing_layer.path.pop_front() 
		player.adjust_position(dot)
		await player.reached_position
	player.playWalkingSound(false)
	player.playAnimation("idle")

func _clear_drawer_path() -> void:
	drawing_layer.path.clear()
	drawing_layer.path.append(player.original_position)  
	drawing_layer.queue_redraw()
	box.freeze = true
	box.linear_velocity = Vector2.ZERO
	box.angular_velocity = 0.0
	await get_tree().process_frame
	PhysicsServer2D.body_set_state(
		box.get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D(0, $BoxStartPos.global_position)  # force physics server position
	)
	box.freeze = false

	player.playAnimation("moving")
	player.adjust_position(player.original_position)
	await player.reached_position  
	player.playAnimation("idle")
	
	gate7.set_deferred("disabled", false)
	
	


func _on_exit_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("PLAYER EXIT")
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			hud.play_level_finished_sound(5)
			await get_tree().create_timer(2.0).timeout
			hud._on_reset_button_pressed()
			get_tree().change_scene_to_file("res://levels/Level6.tscn")

func on_pressure_plate_pressed():
	gate7.set_deferred("disabled", true)
	gateparticle.one_shot = true
	gateparticle.emitting = true
	
func on_pressure_plate_exited():
	gate7.set_deferred("disabled", false)

	
