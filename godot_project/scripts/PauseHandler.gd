extends Spatial

signal game_pause()
signal game_resume()

func _ready():
	#This script needs to have the pause mode set to process so it can keep
	#receiving events even if the whole game is paused
	self.pause_mode = Node.PAUSE_MODE_PROCESS

var is_pause = false

func set_pause(value):
	print ("Set pause mode")
	if value and not is_pause:
		is_pause = true
		get_tree().paused = true
		emit_signal("game_pause")
	elif not value and is_pause:
		get_tree().paused = false
		emit_signal("game_resume")
		is_pause = false
	else:
		print ("State already set")

func _on_headset_mounted():
	print ("UNPAUSE")
	set_pause(false)
	
func _on_headset_unmounted():
	print ("PAUSE")
	set_pause(true)

func connect_to_signals():
	print ("Pause Handler connecting signals")
	if Engine.has_singleton("OVRMobile"):
		var singleton = Engine.get_singleton("OVRMobile")
		print("Connecting to OVRMobile signals")
		singleton.connect("HeadsetMounted", self, "_on_headset_mounted")
		singleton.connect("HeadsetUnmounted", self, "_on_headset_unmounted")
		#singleton.connect("InputFocusGained", self, "_on_input_focus_gained")
		#singleton.connect("InputFocusLost", self, "_on_input_focus_lost")
		#singleton.connect("EnterVrMode", self, "_on_enter_vr_mode")
		#singleton.connect("LeaveVrMode", self, "_on_leave_vr_mode")

#React to android signals
func _notification(what):
        if (what == NOTIFICATION_APP_PAUSED):
                set_pause(true)
        if (what == NOTIFICATION_APP_RESUMED):
                #_need_settings_refresh = true;
                set_pause(false)


#This is only for testing
func _input(ev):
	if not GameVariables.vr_mode:
		if ev is InputEventKey:
			if ev.scancode == KEY_M and ev.pressed:
				_on_headset_mounted()
			elif ev.scancode == KEY_U and ev.pressed:
				_on_headset_unmounted()
				
				
				
				
