extends StaticBody

var beast_mode = false

func update_text():
	get_node("Spatial").print_info("Toggle beast mode\n\nExtend by making a fist")

func _ready():
	update_text()

func touched_by_controller(body, root):
	beast_mode = not beast_mode
	root.set_beast_mode(beast_mode)
	update_text()
