extends KinematicBody2D

var velocity = Vector2(0,0)
var animated = false
var bump_return = false

onready var sprite_box = $Sprite_Box
onready var sprite = $Sprite_Box/Sprite

func _ready():
	pass

func _process(delta):
	var sprite_pos_abs = sprite_box.position.abs()
	
	if sprite_pos_abs.x >= 5 or sprite_pos_abs.y >= 5:
		bump_return = true
		velocity *= -1
	
	if bump_return and sprite_pos_abs.x <= 0.5 and sprite_pos_abs.y <= 0.5:
		velocity = Vector2(0, 0)
		sprite_box.position = Vector2(0, 0)
		bump_return = false
		animated = false
	
	sprite_box.position += velocity * delta

func get_type():
	return Constant.Entity_types.DAGGER

func bump(direction):
	if !animated:
		animated = true
		velocity = direction * 40

func attach(vector):
	var pos_str = String(vector)
	var rotations = {
		"(0, 1)": 0,
		"(-1, 1)": 45,
		"(-1, 0)": 90,
		"(-1, -1)": 135,
		"(0, -1)": 180,
		"(1, -1)": 225,
		"(1, 0)": 270,
		"(1, 1)": 315
	}
	
	sprite.rotation_degrees = rotations[pos_str]

func rotate_self(cw):
	var degree
	
	if cw:
		degree = 45
	else:
		degree = -45
	
	sprite.rotation_degrees += degree

func get_rotation_vector(cw, difference):
	if difference.x == 0:
		if difference.y == 1:
			if cw:
				return Vector2(1, 0)
			else:
				return Vector2(-1, 0)
		else:
			if cw:
				return Vector2(-1, 0)
			else:
				return Vector2(1, 0)
	else:
		if difference.y == 0:
			if difference.x == 1:
				if cw:
					return Vector2(0, -1)
				else:
					return Vector2(0, 1)
			else:
				if cw:
					return Vector2(0, 1)
				else:
					return Vector2(0, -1)
		else:
			if difference.x == 1:
				if difference.y == 1:
					if cw:
						return Vector2(1, 0)
					else:
						return Vector2(0, 1)
				else:
					if cw:
						return Vector2(0, -1)
					else:
						return Vector2(1, 0)
			else:
				if difference.x == -1:
					if difference.y == 1:
						if cw:
							return Vector2(0, 1)
						else:
							return Vector2(-1, 0)
					else:
						if cw:
							return Vector2(-1, 0)
						else:
							return Vector2(0, -1)
	
	print('rotate error')
	return Vector2(0, 0)
		
