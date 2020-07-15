extends Spatial
export var default_text = "demotext"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_info(default_text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass		

func print_info(text):
	get_node("ViewportInfo/CanvasLayer/Container/Text").text = text
	get_node("ViewportInfo").render_target_update_mode = Viewport.UPDATE_ONCE
