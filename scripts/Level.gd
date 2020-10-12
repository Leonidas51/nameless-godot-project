extends Node2D

onready var name_label = get_node("LevelUI/TextContainer/Label")

func _ready():
	pass

func show_name(name):
	name_label.text = name
