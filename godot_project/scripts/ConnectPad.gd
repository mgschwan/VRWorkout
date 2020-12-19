extends Spatial

var is_pressed = false
var last_position = Vector2(0,0)

var multiplayer_room = null


func _ready():
	if len(OS.get_cmdline_args()) > 0:
		var arg = OS.get_cmdline_args()[0]
		if arg.find("room:") >= 0:
			get_node("Viewport/CanvasLayer/Code").text = arg.split(":")[1]
	multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")

var frame_count = 0
func _process(delta):
	if frame_count == 0:
		if multiplayer_room.room and multiplayer_room.room != get_node("Viewport/CanvasLayer/Code").text :
			 get_node("Viewport/CanvasLayer/Code").text = multiplayer_room.room
	frame_count = (frame_count + 1)%20


#func release_event():
#	if is_pressed:
#		is_pressed = false
#		print ("Release event")
#		var ev = InputEventMouseButton.new()
#		ev.button_index=BUTTON_LEFT
#		ev.pressed = false
#		ev.position = last_position
#		get_node("Viewport").input(ev)
#	else:
#		print ("Release without click not possible")
#
#func click_event(position):
#	var viewport = get_node("Viewport")
#	var ev = InputEventMouseButton.new()
#
#	if is_pressed:
#		#We don't want a release/click event so it's either release
#		#or click not both
#		print ("Is clicked. Release first")
#		release_event()
#	else:
#		ev.button_index=BUTTON_LEFT
#		ev.pressed = true
#		ev.position = Vector2(viewport.size[0]*position[0], viewport.size[1]*position[1])
#		last_position = ev.position
#		is_pressed = true
#
#		print ("P: %s"%str(ev.position))
#		viewport.input(ev)

var last_click_time = 0

func manual_button_click(position):
	var viewport = get_node("Viewport")
	var input_point = Vector2(viewport.size[0]*position[0], viewport.size[1]*position[1])
	var base = get_node("Viewport/CanvasLayer")
	for item in base.get_children():
		#print ("Check item: %s"%item.name)
		if item is BaseButton:
			#print ("Check %s in %s/%s"%[str(input_point),str(item.rect_global_position), str(item.rect_size)])
			var point = input_point - item.rect_global_position
			if point.x > 0 and point.x < item.rect_size.x and \
			   point.y > 0 and point.y < item.rect_size.y:
				print ("Clicked: %s"%item.name)
				$AudioStreamPlayer.play()
				item.emit_signal("pressed")

func _on_ConnectPadInput_interface_touch(u, v):	
	if OS.get_ticks_msec() > last_click_time + 200:
		last_click_time = OS.get_ticks_msec() 
		manual_button_click(Vector2(v,u))
		var label = get_node("Viewport/CanvasLayer/Label")
		label.anchor_left = v
		label.anchor_top = u
#		print ("Anchors: %f %f"%[label.anchor_left, label.anchor_top])
#		click_event(Vector2(v,u))
#	else:
#		print ("Debounce block")

func _on_ConnectPadInput_interface_release(u, v):
	#var label = get_node("Viewport/CanvasLayer/Label")
	#release_event()
	pass
func _on_Button_button_down(character):
	get_node("Viewport/CanvasLayer/Code").text += character


func _on_Clear_button_down():
	get_node("Viewport/CanvasLayer/Code").text = ""


func _on_CreateRoom_button_down():
	if multiplayer_room:
		multiplayer_room.connect_to_server(GameVariables.multiplayer_server, "")
	
func _on_ExitRoom_button_down():
	if multiplayer_room:
		multiplayer_room.disconnect_from_server()


func _on_Enter_Room_pressed():
	#TODO: check if it's already connected and handle accordingly
	if multiplayer_room:
		multiplayer_room.connect_to_server(GameVariables.multiplayer_server, get_node("Viewport/CanvasLayer/Code").text)
	 
