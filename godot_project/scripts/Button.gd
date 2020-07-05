extends StaticBody

export var ontext = "On"
var is_active = false

signal selected()

func _ready():
	show_selector(is_active)
	get_node("ontext").print_info(ontext)
	
func touched_by_controller(body, root):
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected")

func show_selector(state):
	if state:
		get_node("Selector").show()
	else:
		get_node("Selector").hide()
	is_active = state
