extends Spatial
export var default_text = "demotext"
export var default_color_name = "white"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_info(default_text, default_color_name)
	#set_texture(get_node("Viewport").get_texture())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func print_info(text, color = "white"):
	var text_node = get_node("Viewport/CanvasLayer/BGPanel/Panel/Container/Text")
	text_node.text = text
	
	var font_color = Color.white
	if color == "red":
		font_color = Color.red
	elif color == "green":
		font_color = Color.green
	elif color == "blue":
		font_color = Color.blue
	text_node.add_color_override("font_color", font_color)
	get_node("Viewport").set_update_mode(Viewport.UPDATE_ONCE)
	
