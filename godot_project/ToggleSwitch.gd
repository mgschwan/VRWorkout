extends StaticBody

export var value = false
export var ontext = "On"
export var offtext = "Off"

signal toggled(value)

func _ready():
	get_node("ontext").print_info(ontext)
	get_node("offtext").print_info(offtext)
	update_switch()
	
func touched_by_controller(body, root):
	value = not value
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("toggled", value)
	update_switch()

func update_switch():
	var switch = get_node("switch")
	if value:
		switch.translation.y = 0.06
	else:
		switch.translation.y = -0.06
