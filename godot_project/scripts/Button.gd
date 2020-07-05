extends StaticBody

export var ontext = "On"


signal selected()

func _ready():
	get_node("ontext").print_info(ontext)
	
func touched_by_controller(body, root):
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected")

