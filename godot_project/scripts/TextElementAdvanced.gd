extends Spatial

export(String) var text = "default"

var textnode
export(int) var font_size = 32
export(int) var viewport_width = 256
export(int) var viewport_height = 64


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var viewport

# Called when the node enters the scene tree for the first time.
func _ready():
	viewport = get_node("Viewport")	

	viewport.size = Vector2(viewport_width,viewport_height)

	textnode = viewport.get_node("CanvasLayer/Container/Label")
	#viewport.get_node("CanvasLayer/Container").rect_size = Vector2(viewport_width/0.8,viewport_height/0.8)
	
	var textmesh = get_node("MeshInstance")

	var font = textnode.get("custom_fonts/font")


	if font.size != font_size:
		#Make a local copy of the texture
		print ("Font needs copying")
		#Custom size needs a local copy of the font
		var font_copy = font.duplicate(true)
		textnode.set("custom_fonts/font", font_copy)
		font_copy.size = font_size
		
	textmesh.set_surface_material(0,textmesh.get_surface_material(0).duplicate())
		
	textmesh.mesh.size = Vector2(2, 2*float(viewport_height)/float(viewport_width))
	
	print_info(text)

func print_info(t):
	text = t.replace("\\n","\n")
	textnode.text = text
	viewport.render_target_update_mode = Viewport.UPDATE_ONCE





