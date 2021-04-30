extends StaticBody

signal interface_touch(u,v)
signal interface_release(u,v)

func disable():
	$CollisionShape.disabled = true
	hide()
	
func enable():
	$CollisionShape.disabled = false
	show()

func get_touch_position(body):
	var element_size = get_node("MeshInstance").mesh.size

	var u = 0
	var v = 0
	
	if has_node("tl_marker"):
		var tl = get_node("tl_marker").global_transform.origin
		var bl = get_node("bl_marker").global_transform.origin
		var tr = get_node("tr_marker").global_transform.origin

		var local_tr = tr - tl
		var local_bl = bl - tl
		var local_point = body.global_transform.origin - tl
	
		var u_project = local_point.project(local_tr)
		var v_project = local_point.project(local_bl)
		
		if local_tr.length() > 0 and local_bl.length() > 0:
			u = clamp(v_project.length() / local_bl.length(), 0.0, 1.0)
			v = clamp(u_project.length() / local_tr.length(), 0.0, 1.0)
		else:
			#Unable to calculate touch position
			pass
	else:
		var touch_point = self.global_transform.xform_inv(body.global_transform.origin)	
		
		u = clamp((-touch_point.y+element_size[1]/2.0)/element_size[1],0.0,1.0)
		v = clamp((touch_point.z+element_size[0]/2.0)/element_size[0],0.0, 1.0)
		
	#print ("Touch point: %s / (%.2f,%.2f)"%[str(body.global_transform.origin),u,v])
	
	return Vector2(u,v)


func touched_by_controller(body, root):
	print ("Touched by %s"%str(body))
	var touch_position = get_touch_position(body.get_touch_object())
	emit_signal("interface_touch",touch_position[0],touch_position[1])

func released_by_controller(body, root):
	print ("Released by %s"%str(body))
	var touch_position = get_touch_position(body.get_touch_object())
	emit_signal("interface_release",touch_position[0],touch_position[1])
