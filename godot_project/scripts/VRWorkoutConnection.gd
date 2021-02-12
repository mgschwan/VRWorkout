extends Spatial

var api

func _ready():
	api = get_tree().current_scene.get_node("RemoteInterface")
	api.connect("registration_initialized", self, "connect_vrworkout_complete")

	if GameVariables.FEATURE_STORE_COMPATIBILITY:
		#Hide the VRWorkout Connection for now
		get_node("VRWorkoutPanel").print_info("Online Features under construction")
	else:
		get_node("VRWorkoutPanel").print_info("This is for Patreon members and beta testers\n\nTo register your device with the portal push all buttons. You will receive a onetime code that you have to enter in the register device page of the VRWorkout portal dashboard\n\nhttps://portal.vrworkout.at")

func disable_all_connect_switches():
		get_node("VRWorkoutPanel/ConnectSwitch").set_state(false)
		get_node("VRWorkoutPanel/ConnectSwitch2").set_state(false)
		get_node("VRWorkoutPanel/ConnectSwitch3").set_state(false)
	
func connect_vrworkout_complete(onetime_code):
	get_node("VRWorkoutPanel").print_info("Step 2\n\nRegister the device in the portal with the code \n\n%s\n\nCode is valid for 5 minutes"%onetime_code)

var last_connection = 0 #rate limiting for the connections
func connect_vrworkout():
	if api and (last_connection + 2000) < OS.get_ticks_msec():
		get_node("VRWorkoutPanel").print_info("Initiating VRWorkout connection\n\nPlease wait")
		last_connection = OS.get_ticks_msec()
		api.register_device(GameVariables.device_id)

func evaluate_connect_switches():
	var switch1 = get_node("VRWorkoutPanel/ConnectSwitch").value
	var switch2 = get_node("VRWorkoutPanel/ConnectSwitch2").value
	var switch3 = get_node("VRWorkoutPanel/ConnectSwitch3").value

	if switch1 and switch2 and switch3:
		connect_vrworkout()

func _on_ConnectSwitch_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()

func _on_ConnectSwitch2_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()

func _on_ConnectSwitch3_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()
