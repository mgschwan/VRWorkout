extends Spatial

export(String) var text = "default"

var textnode
export(int) var viewport_width = 256
export(int) var viewport_height = 64


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	textnode = get_node("Viewport/CanvasLayer/Panel/Container/Label")
	get_node("Viewport/CanvasLayer/Panel").rect_size = Vector2(viewport_width/0.8,viewport_height/0.8)
	
	
	get_node("MeshInstance").mesh.size = Vector2(2, 2*float(viewport_height)/float(viewport_width))
	get_node("Viewport").size = Vector2(viewport_width,viewport_height)
	print_info(text)

func print_info(t):
	text = t.replace("\\n","\n")
	textnode.text = text
	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE


