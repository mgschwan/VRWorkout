extends Spatial
export var defaultext = "Defaultext"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var textnode 
# Called when the node enters the scene tree for the first time.
func _ready():
	textnode = get_node("Viewport/CanvasLayer/Panel/MarginContainer/RichTextLabel")
	set_text(defaultext)

func set_text(text):
	textnode.bbcode_text = text	


func print_info(text):
	set_text(text)
