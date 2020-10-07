extends ARVRCamera

var last_signifficant_amplitude = 0
var last_signifficant_ts = 0
var average_interval = 0
var avg_y = 0
var smooth_y = 0
var steps = 0
var last_pos = Vector3(0,0,0)
var distance_avg = 0



var keys = {
		KEY_UP: false,
		KEY_DOWN: false,
		KEY_LEFT: false,
		KEY_RIGHT: false,
		KEY_PAGEUP: false,
		KEY_PAGEDOWN: false
}
func manual_position_update(delta):
			if keys[KEY_UP]:
				translation.y += delta
			elif keys[KEY_DOWN]:
				translation.y -= delta
			elif keys[KEY_LEFT]:
				translation.x -= delta
			elif keys[KEY_RIGHT]:
				translation.x += delta
			elif keys[KEY_PAGEUP]:
				translation -= transform.basis.z * delta
			elif keys[KEY_PAGEDOWN]:
				translation += transform.basis.z * delta

func _input(ev):
	if not GameVariables.vr_mode:
		if ev is InputEventKey:
			if ev.scancode in keys:
				keys[ev.scancode] = ev.pressed

#Calculate a running mean of the head height and subtract it from
#the signal (removes the DC component).
#Calculate the average time between peaks (if they are signifficant enough)
func update_positions (pos):
	avg_y = (9*avg_y+pos.y)/10
	var amplitude = pos.y - avg_y
	var i = OS.get_ticks_msec() - last_signifficant_ts
	if sign(amplitude) == sign(last_signifficant_amplitude):
		if abs(amplitude) > abs(last_signifficant_amplitude):
			last_signifficant_amplitude = amplitude
			last_signifficant_ts = OS.get_ticks_msec()
	else:
		if abs(last_signifficant_amplitude) > 0.005 and i < 1000:
			if average_interval == 0:
				average_interval = i #Initialize the first measurement
			else:
				average_interval = (3*average_interval+i)/4 #Average continued measurements
		last_signifficant_amplitude = amplitude
		last_signifficant_ts = OS.get_ticks_msec()
		steps += 1
	if OS.get_ticks_msec() > last_signifficant_ts + 1000:
		last_signifficant_amplitude = 0
		average_interval = 0
		last_signifficant_ts = 0
		steps = 0

var last_max_pos = Vector3(0,0,0)
var total_groove_dist = 0
var last_groove_turn = 0
var average_groove_time = 0
func update_groove (pos):
	var now = OS.get_ticks_msec()
	var dist = pos.distance_to(last_max_pos)
	if dist < total_groove_dist and total_groove_dist > 0.1:
		#Turned
		var delta = (now - last_groove_turn)/1000.0
		average_groove_time = (3*average_groove_time + delta) / 4
		
		last_groove_turn = now
		last_max_pos = pos
		total_groove_dist = 0
	else:
		total_groove_dist =  dist
		
		
func get_groove_bpm():
	var retVal = 1
	if OS.get_ticks_msec() < last_groove_turn + 1000 and average_groove_time > 0 :
		retVal = 60/average_groove_time
	return retVal
	
func get_running_speed():
	var retVal = 0
	if OS.get_ticks_msec() < last_signifficant_ts + 1000 and average_interval > 0 and steps > 3:
		retVal = 1000.0/average_interval
	return retVal
		
var uinterval = 0


var height_warning_level = 0

func calculate_height_warning_level(height):
	var retVal = 0
	if height < 0.17:
		retVal = 4
	elif height < 0.19:
		retVal = 3
	elif height < 0.21:
		retVal = 2
	elif height < 0.25:
		retVal = 1
	return retVal

func _process(delta):
	update_positions(self.translation)	
	update_groove(self.translation)

	var new_warning_level =  calculate_height_warning_level(self.translation.y)
	if new_warning_level != height_warning_level:
		get_node("HUDView").set_warning_level(new_warning_level)
		height_warning_level = new_warning_level
	
	uinterval += 1
	#if uinterval % 50 == 0:
	#	print ("Average groove time: %.f"%average_groove_time)
	#	print ("%.2f "%avg_y + " %.2f"%average_interval + " Steps: %d"%steps +" Speed %.2f"%self.get_running_speed())
	
	if not GameVariables.vr_mode:
		manual_position_update(delta)

	
	
func tint_screen(duration):
	get_node("ScreenTint").show()
	yield(get_tree().create_timer(duration),"timeout")
	get_node("ScreenTint").hide()
		
func blackout_screen(blackout):
	if blackout:
		print ("Blackout screen")
		get_node("Blackout").show()
	else:
		print ("Show screen")
		get_node("Blackout").hide()


func show_hud(show):
	var t = get_node("HUDHideTimer")
	if show:
		if not t.is_stopped():
			t.stop()
		get_node("HUDView").show()
	else:
		if t.is_stopped():
			t.wait_time = 0.2
			t.start()

func _on_HUDHideTimer_timeout():
	get_node("HUDView").hide()
