extends StaticBody

export var beast_mode = false

func _ready():
	update_switch()
	

func touched_by_controller(body, root):
	beast_mode = not beast_mode
	root.set_beast_mode(beast_mode)
	update_switch()

func update_switch():
	var switch = get_node("switch")
	if beast_mode:
		switch.translation.y = 0.06
	else:
		switch.translation.y = -0.06
