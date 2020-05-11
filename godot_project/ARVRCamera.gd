extends ARVRCamera

var last_signifficant_amplitude = 0
var last_signifficant_ts = 0
var average_interval = 0
var avg_y = 0
var smooth_y = 0
var steps = 0
var last_pos = Vector3(0,0,0)
var distance_avg = 0
var vr_mode = true

func _input(ev):
	if not vr_mode:
		if ev is InputEventKey:
			if ev.scancode == KEY_UP:
				translation -= transform.basis.z * 0.1
			elif ev.scancode == KEY_DOWN:
				translation += transform.basis.z * 0.1
			elif ev.scancode == KEY_LEFT:
				rotation.y += 0.1
			elif ev.scancode == KEY_RIGHT:
				rotation.y += -0.1
			elif ev.scancode == KEY_PAGEUP:
				rotation.x += 0.1
			elif ev.scancode == KEY_PAGEDOWN:
				rotation.x -= 0.1


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
		
func get_running_speed():
	var retVal = 0
	if OS.get_ticks_msec() < last_signifficant_ts + 1000 and average_interval > 0 and steps > 3:
		retVal = 1000.0/average_interval
	return retVal
		
var uinterval = 0

func _process(delta):
	update_positions(self.translation)	
	uinterval += 1
	#if uinterval % 50 == 0:
	#	print ("%.2f "%avg_y + " %.2f"%average_interval + " Steps: %d"%steps +" Speed %.2f"%self.get_running_speed())
	
func tint_screen(duration):
	get_node("ScreenTint").show()
	yield(get_tree().create_timer(duration),"timeout")
	get_node("ScreenTint").hide()
		
		
	
