extends StaticBody

var current_controller = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Text").print_info("Touch and hold\nto adjust\nother controller")

func touched_by_controller(obj, root):
	if current_controller == null:
		current_controller = obj #get_tree().current_scene.left_controller
		
		for t in GameVariables.trackers:
			if t and t.controller_id != current_controller.id:
				t.fix_global_transform(true)
	
	
func released_by_controller(obj, root):
	if current_controller != null:
		for t in GameVariables.trackers:
			if t and t.controller_id != current_controller.id:
				t.fix_global_transform(false)
		current_controller = null


