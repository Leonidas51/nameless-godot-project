extends KinematicBody2D

var grid
var velocity = Vector2(0,0)
var animated = false
var bump_return = false

onready var sprite = $Sprite

func _ready():
	grid = get_parent()

func _process(delta):
	var sprite_pos_abs = sprite.position.abs()
	
	if sprite_pos_abs.x >= 5 or sprite_pos_abs.y >= 5:
		bump_return = true
		velocity *= -1
	
	if bump_return and sprite_pos_abs.x <= 0.5 and sprite_pos_abs.y <= 0.5:
		velocity = Vector2(0, 0)
		sprite.position = Vector2(0, 0)
		bump_return = false
		animated = false
	
	sprite.position += velocity * delta

func get_type():
	return Constant.Entity_types.HUMAN

func _input(event):
	if !event.is_pressed():
		return
	
	if event.is_action("move_up"):
		try_move(0, -1)
	elif event.is_action("move_down"):
		try_move(0, 1)
	elif event.is_action("move_left"):
		try_move(-1, 0)
	elif event.is_action("move_right"):
		try_move(1, 0)
	elif event.is_action("move_upleft"):
		try_move(-1, -1)
	elif event.is_action("move_upright"):
		try_move(1, -1)
	elif event.is_action("move_downleft"):
		try_move(-1, 1)
	elif event.is_action("move_downright"):
		try_move(1, 1)
	elif event.is_action("pass"):
		try_move(0, 0)
	elif event.is_action("throw"):
		grid.try_throw()
	elif event.is_action("rotate_cw"):
		grid.get_rotation_tile(true)
	elif event.is_action("rotate_ccw"):
		grid.get_rotation_tile(false)

func try_move(x, y):
	grid.try_move_human(self, x, y)
	
func bump(direction):
	if !animated:
		animated = true
		velocity = direction * 40
