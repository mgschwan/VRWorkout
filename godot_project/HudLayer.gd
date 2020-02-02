extends CanvasLayer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func locate_text_node(type):
	if type == "main":
		return get_node("CenterContainer/Label")
	elif type == "debug":
		return get_node("MarginContainer2/Label")
	else:
		return get_node("MarginContainer/Info")

func print_info(info, type = "standard"):
	locate_text_node(type).text = info

func append_info(info, type = "standard"):
	locate_text_node(type).text += info
