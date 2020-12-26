extends Viewport


var last_click_time = 0

func manual_button_click(position):
	var viewport = self
	var input_point = Vector2(viewport.size[0]*position[0], viewport.size[1]*position[1])
	var base = get_node("CanvasLayer")
	for item in base.get_children():
		print ("Check item: %s"%item.name)
		if item is BaseButton:
			print ("Check %s in %s/%s"%[str(input_point),str(item.rect_global_position), str(item.rect_size)])
			var point = input_point - item.rect_global_position
			if point.x > 0 and point.x < item.rect_size.x and \
			   point.y > 0 and point.y < item.rect_size.y:
				print ("Clicked: %s"%item.name)
				#$AudioStreamPlayer.play()
				item.emit_signal("pressed")

func _on_ConnectPadInput_interface_touch(u, v):	
	if OS.get_ticks_msec() > last_click_time + 200:
		last_click_time = OS.get_ticks_msec() 
		manual_button_click(Vector2(v,u))
		#var label = get_node("Viewport/CanvasLayer/Label")
		#label.anchor_left = v
		#label.anchor_top = u
#		print ("Anchors: %f %f"%[label.anchor_left, label.anchor_top])
#		click_event(Vector2(v,u))
#	else:
#		print ("Debounce block")


func _on_ConnectPadInput_interface_release(u, v):
	pass # Replace with function body.
