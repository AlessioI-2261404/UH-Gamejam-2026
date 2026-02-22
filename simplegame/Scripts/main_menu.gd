# scripts/main_menu.gd
extends Control

@onready var btn_level_1: Button = $HBoxContainer/VBoxContainer2/Level1
@onready var btn_level_2: Button = $HBoxContainer/VBoxContainer2/Level2
@onready var btn_level_3: Button = $HBoxContainer/VBoxContainer2/Level3
@onready var btn_level_4: Button = $HBoxContainer/VBoxContainer3/Level4
@onready var btn_level_5: Button = $HBoxContainer/VBoxContainer3/Level5
@onready var btn_level_6: Button = $HBoxContainer/VBoxContainer3/Level6
@onready var Start: Button = $Start

func _ready() -> void:
	btn_level_1.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level1.tscn")
	)

	btn_level_2.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level2.tscn")
	)

	btn_level_3.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level3.tscn")
	)

	btn_level_4.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level4.tscn")
	)

	btn_level_5.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level5.tscn")
	)

	btn_level_6.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level6.tscn")
	)

	Start.pressed.connect(func():
		get_tree().change_scene_to_file("res://levels/Level1.tscn")
	)
