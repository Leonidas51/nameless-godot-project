extends Node2D

onready var canvas = get_node("ColorRect")

signal dark

var fade = true
var calm = true
const speed = 1

func _ready():
	pass

func _process(delta):
	if calm:
		return
	
	if fade:
		canvas.color.a += speed * delta
		if canvas.color.a >= 1:
			emit_signal("dark")
			canvas.color.a = 1
			fade = false
	else:
		canvas.color.a -= speed * delta
		if canvas.color.a <= 0:
			canvas.color.a = 0
			fade = true
			calm = true

func reset():
	canvas.color.a = 0
	calm = true
	fade = true
