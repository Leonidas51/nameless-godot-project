extends KinematicBody2D
class_name Enemy

var grid
var self_grid_pos
var new_state = {}
var states = []
var is_dead = false

onready var sprite = $Sprite

func _ready():
	push_state({"position": position, "is_dead": is_dead})
	grid = get_parent().get_parent() #никогда не сломается обещаю

func push_state(state):
	states.append(state)

func undo_state():
	var state
	var new_pos

	states.pop_back()
	state = states.back()
	new_pos = grid.world_to_map(state.position)

	if !is_dead:
		move(new_pos.x, new_pos.y)

	if is_dead and !state.is_dead:
		awaken()

func execute_behaviour(human_pos):
	if is_dead:
		turn()
		return
	
	_execute_behaviour(human_pos)

func _execute_behaviour(human_pos):
	turn()

func move(x, y):
	grid.move_enemy(self, x, y)

func die():
	is_dead = true
	sprite.hide()

func awaken():
	is_dead = false
	sprite.show()
	grid.awaken_enemy(self)

func turn():
	push_state({"position": position, "is_dead": is_dead})
