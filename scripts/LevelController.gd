extends Node2D

var current_lv = 0
const LEVEL_LIST = [
	"Welcome", "Fetch Quest", "Chase", "Circles",
	"Trickery", "Patience", "Distance", "Preparations", 
	"Hide and Seek", "On my Tail", "Hallways",
	"Ready, Aim", "Up", "Cavern",
	"Self-defense", "Swordplay", "Surround", "Corridors", "Blocked"
	]
var need_loading = false
var current_lv_box = 1

onready var game = get_node("/root/Game")
onready var lv_select = get_node("/root/Game/level_select")
onready var lv_list_node = get_node("/root/Game/level_select/level_list1")

func _ready():
	for i in range(0, LEVEL_LIST.size()):
		var lv_label = load("res://lv_label.tscn").instance()
		var lv_text = String(i + 1) + ". " + LEVEL_LIST[i]

		lv_label.lv_id = i
		lv_label.set_bbcode('[url=' + String(i) + ']' + lv_text + '[/url]')
		lv_label.push_meta(i)
		lv_label.add_to_group("lv_labels")
		lv_list_node.add_child(lv_label)
		
		if i != 0 and i % 10 == 0:
			current_lv_box += 1
			lv_list_node = get_node("/root/Game/level_select/level_list" + String(current_lv_box))

func _input(event):
	if !event.is_pressed():
		return
	
	if event.is_action("exit"):
		return_to_select()

func return_to_select():
	var lv = game.get_node_or_null("Level")
	if lv:
		lv.queue_free()
		lv_select.show()

func _process(delta):
	if need_loading:
		game.add_child(load("res://levels/" + LEVEL_LIST[current_lv] + ".tscn").instance())
		need_loading = false
	
func on_lv_complete():
	#transition stuff goes here
	get_tree().call_group("lv_labels", "mark_label_complete", current_lv)
	
	current_lv += 1
	if current_lv >= LEVEL_LIST.size():
		return_to_select()
		return
	
	load_new_level()
	

func on_defeat():
	#transition stuff goes here
	
	load_new_level()
	
func restart_lv():
	#transition stuff goes here
	
	load_new_level()

func load_new_level():
	var prev_lv = game.get_node_or_null("Level")
	
	lv_select.hide()
	
	if prev_lv:
		prev_lv.queue_free()
	
	need_loading = true
