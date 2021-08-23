extends Spatial

var api

func _ready():
	api = false
	api = get_tree().current_scene.get_node("HeartRateReceiver").vrhealthAPI
	
	if api != null:
		api.connect("connect_app_initialized", self, "connect_vrhealth_complete")
	
	if api and api.isSetup():
		get_node("VRHealthPanel").print_info("ONLY AVAILBE IN BETA!\nVRHealth connection already setup\n\nPush all buttons to reconnect")
	else:
		get_node("VRHealthPanel").print_info("VRHealth not setup\n\nPush all buttons to connect")

func disable_all_connect_switches():
		get_node("VRHealthPanel/ConnectSwitch").set_state(false)
		get_node("VRHealthPanel/ConnectSwitch2").set_state(false)
		get_node("VRHealthPanel/ConnectSwitch3").set_state(false)
	
func connect_vrhealth_complete(onetime_code):
	get_node("VRHealthPanel").print_info("VRHealth connecting\n\nPress connect in the VRHealth app\nand enter the code\n\n %s"%onetime_code)
	if api:
		api.connectLive()
	
var last_connection = 0 #rate limiting for the connections
func connect_vrhealth():
	if api and (last_connection + 2000) < OS.get_ticks_msec():
		get_node("VRHealthPanel").print_info("Initiating VRHealth connection\n\nPlease wait")
		last_connection = OS.get_ticks_msec()
		api.connectApp(GameVariables.app_name)

func evaluate_connect_switches():
	var switch1 = get_node("VRHealthPanel/ConnectSwitch").value
	var switch2 = get_node("VRHealthPanel/ConnectSwitch2").value
	var switch3 = get_node("VRHealthPanel/ConnectSwitch3").value

	if switch1 and switch2 and switch3:
		connect_vrhealth()	

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
