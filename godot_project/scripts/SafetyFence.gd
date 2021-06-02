extends Spatial

export var max_allowed_distance = 0.6
export var deadzone = 0.2


func get_offset(node, to_front=true):
	var retVal = 0
	var distance_range = max(0,max_allowed_distance - deadzone)

	var fence_origin = global_transform.origin
	var fence_direction = global_transform.basis.z
	var cam_pos = node.global_transform.origin
	var relative_cam_pos = cam_pos - fence_origin
	
	#TODO this does not works if playspace is recentered
	var projected_pos = relative_cam_pos.project(fence_direction)
	var dist = projected_pos.length()
	
	var target_offset = dist - translation.length()
	
	if max_allowed_distance > 0:
		var tmp = target_offset - deadzone
		if to_front:
			tmp = -target_offset - deadzone
		retVal = clamp(tmp, 0.0 , distance_range) / distance_range
	return retVal

var throttle = 0
func _process(delta):
	throttle += 1	
	if throttle > 7:
		throttle = 0
		var front_close = get_offset(GameVariables.vr_camera, true)
		var back_close = get_offset(GameVariables.vr_camera, false)

		$UpperLeft.scale.z = front_close
		$UpperRight.scale.z = front_close
		$LowerLeft.scale.z = back_close
		$LowerRight.scale.z = back_close
		

