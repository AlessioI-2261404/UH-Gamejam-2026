# scripts/main_menu.gd
extends Control

@onready var btn_level_1: Button = $VBoxContainer/Level1
@onready var btn_level_2: Button = $VBoxContainer/Level2

func _ready() -> void:
	btn_level_1.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level1.tscn")
	)

	btn_level_2.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level2.tscn")
	)
