extends Spatial


var hands = null
var feet = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hands = get_node("Hands")
	feet = get_node("Feet")
	
	hands.hide()
	feet.hide()


func show_hands(flag):
	if flag:
		hands.show()
	else:
		hands.hide()
		
func show_feet(flag):
	if flag:
		feet.show()
	else:
		feet.hide()
		
