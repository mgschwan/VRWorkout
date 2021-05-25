extends Spatial

export var max_allowed_distance = 0.6
export var deadzone = 0.2


func get_offset(node, to_front=true):
	var retVal = 0
	var distance_range = max(0,max_allowed_distance - deadzone)
	var origin = get_tree().current_scene.get_node("ARVROrigin")
	
	#TODO this does not works if playspace is recentered
	var projected_pos = origin.global_transform.basis.z.project(node.global_transform.origin-origin.global_transform.origin)
	var dist = projected_pos.length()
	
	#var pos = get_tree().current_scene.get_node("ARVROrigin").to_local(node.translation)
	
	if max_allowed_distance > 0:
#		var dist = pos.z-deadzone
#		if to_front:
#			dist = -pos.z-deadzone
		retVal = clamp(dist, 0.0 , distance_range) / distance_range
	return retVal

func _process(delta):
	var front_close = get_offset(GameVariables.vr_camera, true)
	var back_close = get_offset(GameVariables.vr_camera, false)

	$UpperLeft.scale.z = front_close
	$UpperRight.scale.z = front_close
	$LowerLeft.scale.z = back_close
	$LowerRight.scale.z = back_close
	

