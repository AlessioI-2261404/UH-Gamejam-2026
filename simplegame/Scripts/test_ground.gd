extends Node2D
var p_mode_active := false
var path: Array[Vector2i] = []

@onready var ground_layer = $Ground
@onready var highlight_layer = $Path_Highlight
@onready var player = $Player
@onready var pencil = $HUD/Pencil/pencilBtn

func _on_pencil():
	p_mode_active = true
	path.clear()
	highlight_layer.clear()
	print("P mode active")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pencil.pressed.connect(_on_pencil)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
