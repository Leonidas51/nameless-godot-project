extends RichTextLabel

var lv_id

func _ready():
	set_use_bbcode(true)
	set_meta_underline(false)
	connect("meta_clicked", self, "pressed")

func pressed(meta):
	LevelController.current_lv = int(meta)
	LevelController.load_new_level()

func mark_label_complete(id):
	if lv_id == id:
		set("custom_colors/default_color",Color("#00ab3f"))
