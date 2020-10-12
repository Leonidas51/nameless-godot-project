extends TileMap

var states = []
var grid_size = Vector2(40,22)
var grid = []
var turn_count = 0
var human_pos
var dagger_pos
var dagger_attached = true
var exit_pos
var key_pos
var key_taken = false
var controls_disabled = true

onready var exit = $Exit
onready var key = $Key
onready var human = $Human
onready var dagger = get_node_or_null("Dagger")
onready var enemies = $Enemies

class Tile:
	var surface
	var entities
	
	func _init(s = Constant.Surface_types.VOID, e = []):
		surface = s
		entities = e
	
	func is_traversable():
		if surface in [Constant.Surface_types.FLOOR]:
			return true
			
		return false
	
	func is_vacant():
		if has_enemy():
			return false
		for entity in entities:
			if entity.type in [Constant.Entity_types.DAGGER]:
				return false
		
		return true

	func has_entity_by_type(type):
		for entity in entities:
			if entity.type == type:
				return true
		
		return false
	
	func has_enemy():
		for entity in entities:
			if entity.type in [Constant.Entity_types.SPIDER]:
				return true
		
		return false

	func add_entity(type):
		entities.append({
			"type": type
		})
	
	func clear_entity(type):
		var clear = false
		for n in range(entities.size()):
			if entities[n].type == type:
				entities.remove(n)
				clear = true
				break;
				
		if !clear:
			push_error("no entity to clear")

func _ready():
	human_pos = world_to_map(human.position)
	key_pos = world_to_map(key.position)
	exit_pos = world_to_map(exit.position)
	
	if dagger:
		dagger_pos = world_to_map(dagger.position)
	
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			var cell_id = get_cell(x,y)
			if cell_id == -1:
				grid[x].append(Tile.new())
			if cell_id in [0]: #floor types
				grid[x].append(Tile.new(Constant.Surface_types.FLOOR))
			if cell_id in [1]: #obstacle types
				grid[x].append(Tile.new(Constant.Surface_types.OBSTACLE))

	#add human
	grid[human_pos.x][human_pos.y].add_entity(Constant.Entity_types.HUMAN)
	
	#add key
	grid[key_pos.x][key_pos.y].add_entity(Constant.Entity_types.KEY)
	
	#add exit
	grid[exit_pos.x][exit_pos.y].add_entity(Constant.Entity_types.EXIT)
	
	#add dagger
	if dagger:
		grid[dagger_pos.x][dagger_pos.y].add_entity(Constant.Entity_types.DAGGER)
		attach_dagger(human_pos)
	
	#add enemies
	for enemy in enemies.get_children():
		var enemy_pos = world_to_map(enemy.position)
		grid[enemy_pos.x][enemy_pos.y].add_entity(enemy.get_type())
	
	controls_disabled = false
	push_state()

func _input(event):
	if event.is_action_pressed("undo"):
		if states.size() >= 2:
			undo_state()
	elif event.is_action("restart"):
		LevelController.restart_lv()

func turn():
	turn_count = turn_count + 1

	for enemy in enemies.get_children():
		var enemy_pos = world_to_map(enemy.position)
		var enemy_tile = grid[enemy_pos.x][enemy_pos.y]
		
		if enemy_tile.has_entity_by_type(Constant.Entity_types.DAGGER):
			if !enemy.is_dead:
				enemy.die()
				enemy_tile.clear_entity(enemy.get_type())
		
		enemy.execute_behaviour(human_pos)
		
	if grid[human_pos.x][human_pos.y].has_enemy():
		controls_disabled = true
		LevelController.on_defeat()
		
	if !key_taken and grid[human_pos.x][human_pos.y].has_entity_by_type(Constant.Entity_types.KEY):
		grid[human_pos.x][human_pos.y].clear_entity(Constant.Entity_types.KEY)
		key_taken = true
		key.hide()

	if exit_pos == human_pos and key_taken:
		controls_disabled = true
		LevelController.on_lv_complete()
		
	push_state()

func push_state():
	var new_state = {}

	new_state.human_pos = human_pos
	if dagger:
		new_state.dagger_pos = dagger_pos
		new_state.dagger_attached = dagger_attached
		new_state.dagger_rotation = dagger.sprite.rotation_degrees
	new_state.key_taken = key_taken

	states.append(new_state)

func undo_state():
	var state
	
	states.pop_back()
	state = states.back()
	
	LevelController.undo_defeat()
	
	move_entity(human, human_pos, state.human_pos)
	if dagger:
		move_entity(dagger, dagger_pos, state.dagger_pos)
		dagger.sprite.rotation_degrees = state.dagger_rotation
		dagger_attached = state.dagger_attached

	key_taken = state.key_taken
	
	if !key_taken:
		grid[key_pos.x][key_pos.y].add_entity(Constant.Entity_types.KEY)
		key.show()

	for enemy in enemies.get_children():
		enemy.undo_state()
	
	controls_disabled = false

func try_move_human(human, x, y):
	var new_human_pos = world_to_map(human.position) + Vector2(x, y)
	var new_dagger_pos
	var dagger_tile_movable = true

	if controls_disabled:
		return

	if dagger:
		if !dagger_attached:
			new_dagger_pos = world_to_map(dagger.position)
		else:
			new_dagger_pos = world_to_map(dagger.position) + Vector2(x, y)
			dagger_tile_movable = is_cell_movable(new_dagger_pos, false, true)
	
	if is_cell_movable(new_human_pos, true) and dagger_tile_movable:
		if !dagger_attached and grid[new_human_pos.x][new_human_pos.y].has_entity_by_type(Constant.Entity_types.DAGGER):
			human.bump(Vector2(x, y))
			attach_dagger(new_human_pos)
			turn()
		else:
			move_entity(human, world_to_map(human.position), new_human_pos)
			if dagger:
				move_entity(dagger, world_to_map(dagger.position), new_dagger_pos)
			turn()
	else:
		human.bump(Vector2(x, y))
		if dagger and dagger_attached:
			dagger.bump(Vector2(x, y))

func get_rotation_tile(cw):
	var rotation_vector
	var new_pos
	
	if controls_disabled or !dagger or !dagger_attached:
		return
	
	rotation_vector = dagger.get_rotation_vector(cw, human_pos - dagger_pos)
	new_pos = dagger_pos + rotation_vector
	
	if is_cell_movable(new_pos, false, true):
		move_entity(dagger, dagger_pos, new_pos)
		dagger.rotate_self(cw)
		turn()
	else:
		dagger.bump(new_pos - dagger_pos)

func try_rotate(new_pos, cw):
	if is_cell_movable(new_pos, false, true):
		move_entity(dagger, dagger_pos, new_pos)
		dagger.rotate_self(cw)
		turn()
	else:
		dagger.bump(new_pos - dagger_pos)

func try_throw():
	if controls_disabled or !dagger_attached:
		return
		
	var throw_vector = dagger_pos - human_pos
	
	if is_cell_movable(dagger_pos + throw_vector, false, true):
		dagger_attached = false
		while (is_cell_movable(dagger_pos + throw_vector, false, true)):
			move_entity(dagger, dagger_pos, dagger_pos + throw_vector)
			if grid[dagger_pos.x][dagger_pos.y].has_enemy():
				break
		turn()

func attach_dagger(pos):
	dagger_attached = true
	dagger.attach(human_pos - dagger_pos)

func move_enemy(enemy, x, y):
	var new_grid_pos = Vector2(x, y)

	move_entity(enemy, world_to_map(enemy.position), new_grid_pos)

func awaken_enemy(enemy):
	var enemy_pos = world_to_map(enemy.position)
	
	grid[enemy_pos.x][enemy_pos.y].add_entity(enemy.get_type())

func move_entity(entity, start, finish):
	grid[start.x][start.y].clear_entity(entity.get_type())
	grid[finish.x][finish.y].add_entity(entity.get_type())
	
	if entity.get_type() == Constant.Entity_types.HUMAN:
		human_pos = Vector2(finish.x, finish.y)
	
	if entity.get_type() == Constant.Entity_types.DAGGER:
		dagger_pos = Vector2(finish.x, finish.y)

	update_sprite(entity, start, finish)

func is_cell_movable(pos, ignore_dagger = false, ignore_enemies = false):
	var tile = grid[pos.x][pos.y]

	if ignore_enemies:
		return tile.is_traversable()

	if ignore_dagger:
		return !tile.has_enemy() and tile.is_traversable()

	return (tile.is_vacant() and tile.is_traversable())

func get_adjacent(pos):
	var adjacent = []
	
	# top adjacent
	adjacent += [grid[pos.x - 1][pos.y - 1], grid[pos.x][pos.y - 1], grid[pos.x + 1][pos.y - 1]]
	# bottom adjacent
	adjacent += [grid[pos.x - 1][pos.y + 1], grid[pos.x][pos.y + 1], grid[pos.x + 1][pos.y + 1]]
	# sides adjacent
	adjacent += [grid[pos.x - 1][pos.y], grid[pos.x + 1][pos.y]]
	
	return adjacent

func update_sprite(entity, start, finish):
	entity.position = map_to_world(finish)
