extends Spatial


# Called when the node enters the scene tree for the first time.
func _ready():
	play("runforpoints")

var currently_running = ""

func play(name):
	for n in get_node("speed_text").get_children():
		if n.name == name:
			n.show() 
		else:
			n.hide()

func stop():
	play("runforpoints")
