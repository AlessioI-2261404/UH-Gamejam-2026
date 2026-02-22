extends AnimatedSprite2D

var tool_id: int = 0  # 0=NONE, 1=PENCIL, 2=ERASE

func _ready():
	play("default")

func _process(_delta):
	global_position = get_global_mouse_position()

func set_default_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	play("default")
	scale = Vector2(1.0, 1.0)

func set_eraser_cursor():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	play("erase")
	scale = Vector2(0.2, 0.2)

func set_pencil_cursor(state: int = 0):
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	var anim: String = ["100%", "75%", "50%", "25%", "0%"][state]
	play("pencil" + anim)
	scale = Vector2(0.5, 0.5)
