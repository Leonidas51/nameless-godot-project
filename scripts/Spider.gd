extends Enemy

func get_type():
	return Constant.Entity_types.SPIDER

func _execute_behaviour(human_pos):
	self_grid_pos = grid.world_to_map(position)
	var x = 0
	var y = 0
	
	if self_grid_pos.x > human_pos.x:
		x = -1
	elif self_grid_pos.x < human_pos.x:
		x = 1
	
	if self_grid_pos.y > human_pos.y:
		y = -1
	elif self_grid_pos.y < human_pos.y:
		y = 1
	
	find_best_action(x, y)

func find_best_action(x, y):
	x = self_grid_pos.x + x
	y = self_grid_pos.y + y
	
	if grid.is_cell_movable(Vector2(x, y)):
		move(x, y)
	elif x != 0 and y != 0:
		if grid.is_cell_movable(Vector2(self_grid_pos.x, y)):
			move(self_grid_pos.x, y)
		elif grid.is_cell_movable(Vector2(x, self_grid_pos.y)):
			move(x, self_grid_pos.y)
			
	turn()
