extends Spatial
export var default_text = "demotext"

export(bool) var bbtext = false 
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print_info(default_text.replace("\\n","\n"))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass		

func print_info(text):
	var n = get_node("ViewportInfo/CanvasLayer/Container/Text")
	if bbtext:
		if "bbcode_enabled" in n:
			n.bbcode_enabled = true 
		n.bbcode_text = text
	else:
		if "bbcode_enabled" in n:
			n.bbcode_enabled = false 
		n.text = text
	get_node("ViewportInfo").render_target_update_mode = Viewport.UPDATE_ONCE
