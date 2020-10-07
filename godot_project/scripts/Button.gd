extends StaticBody

export(int) var font_size = 32
export var ontext = "On"
var is_active = false
export(AudioStream) var select_sound = null

signal selected()

func _enter_tree():
	get_node("ontext").font_size = font_size

func _ready():
	show_selector(is_active)
	get_node("ontext").print_info(ontext)
	if select_sound:
		get_node("AudioStreamPlayer").stream = select_sound
	
func touched_by_controller(body, root):
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected")

func show_selector(state):
	if state:
		get_node("Selector").show()
	else:
		get_node("Selector").hide()
	is_active = state
