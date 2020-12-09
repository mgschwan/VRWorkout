extends StaticBody

signal interface_touch(u,v)
signal interface_release(u,v)

func get_touch_position(body):
	var touch_point = self.global_transform.xform_inv(body.global_transform.origin)

	var element_size = get_node("MeshInstance").mesh.size
	
	var u = clamp((-touch_point.y+element_size[1]/2.0)/element_size[1],0.0,1.0)
	var v = clamp((touch_point.z+element_size[0]/2.0)/element_size[0],0.0, 1.0)
	return Vector2(u,v)


func touched_by_controller(body, root):
	var touch_position = get_touch_position(body)
	emit_signal("interface_touch",touch_position[0],touch_position[1])

func released_by_controller(body, root):
	var touch_position = get_touch_position(body)
	emit_signal("interface_release",touch_position[0],touch_position[1])
