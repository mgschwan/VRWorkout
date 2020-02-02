extends MeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("difficulty").print_info("Touch pole to\nset difficulty")

func set_difficulty(d):
	get_node("marker").translation.y = (-d+1)*0.5
