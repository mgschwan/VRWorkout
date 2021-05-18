extends Spatial

export var max_allowed_distance = 0.6
export var deadzone = 0.2


func get_offset(node, to_front=true):
	var retVal = 0
	var distance_range = max(0,max_allowed_distance - deadzone)
	if max_allowed_distance > 0:
		var dist = node.translation.z-deadzone
		if to_front:
			dist = -node.translation.z-deadzone
		retVal = clamp(dist, 0.0 , distance_range) / distance_range
	return retVal

func _process(delta):
	var front_close = get_offset(GameVariables.vr_camera, true)
	var back_close = get_offset(GameVariables.vr_camera, false)

	$UpperLeft.scale.z = front_close
	$UpperRight.scale.z = front_close
	$LowerLeft.scale.z = back_close
	$LowerRight.scale.z = back_close
	

