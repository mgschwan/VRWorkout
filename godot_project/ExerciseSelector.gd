extends Spatial

signal selected(type)

export var selected = "stand"
var step = -1.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	update_selector()

func update_selector():
	var index = 0
	if selected == "stand":
		index = 0
	elif selected == "squat":
		index = 1
	elif selected == "pushup":
		index = 2
	elif selected == "jump":
		index = 3
	elif selected == "crunch":
		index = 4
	elif selected == "burpee":
		index = 5

	get_node("highlight").translation.z = step*index

func select(item):
	selected = item
	update_selector()


func _on_SignBody_selected(item):
	select(item)	
	emit_signal("selected",item)
