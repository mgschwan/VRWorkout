extends StaticBody

export(StreamTexture) var image 
export(AudioStream) var select_sound = null
export(String) var active_marker = ""

func _ready():
	get_node("Viewport/CanvasLayer/TextureRect").texture = image
	if select_sound:
		get_node("AudioStreamPlayer").stream = select_sound

signal selected()
signal selected_by(controller)
	
func touched_by_controller(body, root):
	print ("Panel touched")
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected")
	emit_signal("selected_by", body)

func mark_active(value = true):
	var node = get_parent().get_node(active_marker)
	if node:
		if value:
			node.show()
			node.translation = self.translation
		else:
			node.hide()

func set_image(imagepath):
	var img = load(imagepath)
	
	get_node("Viewport/CanvasLayer/TextureRect").texture = img
	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE
