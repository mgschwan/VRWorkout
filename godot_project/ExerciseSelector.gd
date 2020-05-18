extends Spatial

signal selected(type)

export var selected = "stand"
var step = -1.5

var first_hit = ""

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
	elif selected == "sprint":
		index = 6

	get_node("highlight").translation.z = step*index

func select(item):
	selected = item
	update_selector()

#Sign has to be hit twice to prevent accidential selection
func _on_SignBody_selected(item):
	if item == first_hit:
		select(item)	
		emit_signal("selected",item)
		first_hit = ""
	else:
		first_hit = item
