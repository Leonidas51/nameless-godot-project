extends RichTextLabel

var lv_id

func _ready():
	set_use_bbcode(true)
	set_meta_underline(false)
	connect("meta_clicked", self, "pressed")

func pressed(meta):
	LevelController.current_lv = int(meta)
	LevelController.load_new_level()
