extends Area2D

@export_file("*.tscn") var next_scene: String

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
