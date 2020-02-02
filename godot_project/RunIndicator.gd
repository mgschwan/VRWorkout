extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for n in get_children():
		n.hide()

var currently_running = ""

func play(name):
	if name != currently_running:
		stop()

	if currently_running == "":
		var root = get_node(name)
		root.show()
		var n = root.get_node("AnimationPlayer")
		n.get_animation("TextAction").set_loop(true)
		n.play("TextAction")
		currently_running = name

func stop():
	if currently_running != "":
		for n in get_children():
			if n.visible:
				n.hide()
				n.get_node("AnimationPlayer").stop()
		currently_running = ""	
