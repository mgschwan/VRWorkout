extends StaticBody

var current_controller = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Text").print_info("Touch and hold\nto adjust\nother controller")

func touched_by_controller(obj, root):
	if current_controller == null:
		current_controller = get_tree().current_scene.left_controller
		
		if obj.is_left:
			current_controller = get_tree().current_scene.right_controller
		
		if current_controller:
			current_controller.fix_global_transform(true)
	
	
func released_by_controller(obj, root):
	if current_controller != null:
		current_controller.fix_global_transform(false)
		current_controller = null


