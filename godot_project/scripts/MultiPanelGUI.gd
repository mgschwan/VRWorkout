extends Spatial

var gu = GameUtilities.new()


func _on_SetWeightBar_selected_by(controller):
	var new_controller = get_tree().current_scene.create_controller("weightbar", controller.controller_id, "controller")
	
	var main_controller = ""
	if get_tree().current_scene.left_controller == controller:
		main_controller = "left"
		get_tree().current_scene.left_controller = null
	elif get_tree().current_scene.right_controller == controller:
		main_controller = "right"
		get_tree().current_scene.right_controller = null
	
	get_tree().current_scene.replace_tracker(controller, new_controller)
	
	#Tell the system to keep the tracker visible if it's removed
	var tracker_identifier = gu.get_tracker_id(new_controller)
	var tracker_config = gu.get_tracker_config(tracker_identifier)
	tracker_config["should_persist"] = true
	gu.set_tracker_config(tracker_identifier, tracker_config)
	
	if main_controller == "left":
		get_tree().current_scene.left_controller = new_controller
	elif main_controller == "right":
		get_tree().current_scene.right_controller = new_controller

func _on_MultiPanel_activate_feature(feature, active):
	if feature == "weights":
		if active:
			$SetWeightBar.translation.z = 0.57
		else:
			$SetWeightBar.translation.z = -2
		
		
		
