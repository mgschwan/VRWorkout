extends Spatial

var min_val = 0.0
var max_val = 20.0

var actual = 0

var value_text = null

func _ready():
	value_text = get_node("Viewport/CanvasLayer/Label") 

func set_value(value):
	actual = value
	value_text.text = "%.1f"%value
	update_markers()

func update_markers():
	var delta = max(1.0,max_val-min_val)	
	get_node("Circle/actual").rotation.y = 3*PI/2 - deg2rad(min_val + 360 * actual/delta)

func _process(delta):
	pass
