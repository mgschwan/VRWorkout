extends Viewport


var last_click_time = 0

func manual_button_click(position):
	var viewport = self
	var input_point = position
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


var last_position = Vector2(0,0)
var is_pressed = false
func release_event(position = null):
	var viewport = self
	if is_pressed:
		is_pressed = false
		print ("Release event")
		var ev = InputEventMouseButton.new()
		ev.button_index=BUTTON_LEFT
		ev.pressed = false
		if position is Vector2:
			ev.position = position
		else:
			ev.position = last_position
		viewport.input(ev)
	else:
		print ("Release without click not possible")

func click_event(position):
	var viewport = self
	var ev = InputEventMouseButton.new()

	if is_pressed:
		#We don't want a release/click event so it's either release
		#or click not both
		print ("Is clicked. Release first")
		release_event()
	else:
		ev.button_index=BUTTON_LEFT
		ev.pressed = true
		ev.position = position
		last_position = ev.position
		is_pressed = true

		print ("P: %s"%str(ev.position))
		viewport.input(ev)

func _on_ConnectPadInput_interface_touch(u, v):	
	if OS.get_ticks_msec() > last_click_time + 200:
		var position = Vector2(self.size[0]*v, self.size[1]*u)		
		
		last_click_time = OS.get_ticks_msec() 
		click_event(position)
		#manual_button_click(Vector2(v,u))
		if has_node("CanvasLayer/Mark"):
			var label = get_node("CanvasLayer/Mark")
			label.rect_position = position
			print ("Anchors: %f %f"%[position.x, position.y])
#		click_event(Vector2(v,u))
#	else:
#		print ("Debounce block")


func _on_ConnectPadInput_interface_release(u, v):
	release_event() #Vector2(v,u))
