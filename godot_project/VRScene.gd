extends Spatial

var level_blueprint = preload("res://Level.tscn")
var levelselect_blueprint = preload("res://Levelselect.tscn")
var levelselect
var level = null
var cam = null
var difficulty = 0
var height = 1.8
var vr_mode = true
export var beast_mode = false


var left_controller
var right_controller
var left_collision_root
var right_collision_root
var ball_l 
var ball_r

var in_hand_mode = false #auto detect hand_mode, can't revert back automatically
var player_height_stat = []


var total_points = 0
var last_points = 0
var total_played = 0
var last_played = 0


var ovr_init_config = null;
var _vrapi_bone_orientations = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];

var ovr_performance = null;
var ovr_display_refresh_rate = null;
var ovr_guardian_system = null;
var ovr_tracking_transform = null;
var ovr_utilities = null;
var ovr_vr_api_proxy = null;

var ovr_hand_tracking = null;

var arvr_ovr_mobile_interface = null;
var arvr_oculus_interface = null;
var arvr_open_vr_interface = null;

func setup_globals():
	ProjectSettings.set("game/beast_mode", false)


func _initialize_OVR_API():
	# load the .gdns classes.
	ovr_display_refresh_rate = load("res://addons/godot_ovrmobile/OvrDisplayRefreshRate.gdns");
	ovr_guardian_system = load("res://addons/godot_ovrmobile/OvrGuardianSystem.gdns");
	ovr_performance = load("res://addons/godot_ovrmobile/OvrPerformance.gdns");
	ovr_tracking_transform = load("res://addons/godot_ovrmobile/OvrTrackingTransform.gdns");
	ovr_utilities = load("res://addons/godot_ovrmobile/OvrUtilities.gdns");
	ovr_hand_tracking = load("res://addons/godot_ovrmobile/OvrHandTracking.gdns");
	ovr_vr_api_proxy = load("res://addons/godot_ovrmobile/OvrVrApiProxy.gdns");

	# and now instance the .gdns classes for use if load was successfull
	if (ovr_display_refresh_rate): ovr_display_refresh_rate = ovr_display_refresh_rate.new()
	if (ovr_guardian_system): ovr_guardian_system = ovr_guardian_system.new()
	if (ovr_performance): ovr_performance = ovr_performance.new()
	if (ovr_tracking_transform): ovr_tracking_transform = ovr_tracking_transform.new()
	if (ovr_utilities): ovr_utilities = ovr_utilities.new()


func initialize():
	var arvr_ovr_mobile_interface = ARVRServer.find_interface("OVRMobile");
	var arvr_oculus_interface = ARVRServer.find_interface("Oculus");
	var arvr_open_vr_interface = ARVRServer.find_interface("OpenVR");
	
	
	vr_mode = false
	cam = get_node("ARVROrigin/ARVRCamera")

	if arvr_ovr_mobile_interface:
		# the init config needs to be done before arvr_interface.initialize()
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
		if (ovr_init_config):
			ovr_init_config = ovr_init_config.new()
			ovr_init_config.set_render_target_size_multiplier(1) # setting to 1 here is the default
		
		if arvr_ovr_mobile_interface.initialize():
			get_viewport().arvr = true
			get_viewport().hdr = false
			OS.vsync_enabled = false
			Engine.target_fps = 72
			_initialize_OVR_API()
			vr_mode = true
	elif arvr_oculus_interface:
		if arvr_oculus_interface.initialize():
			vr_mode = true
			get_viewport().arvr = true;
			Engine.target_fps = 80 # TODO: this is headset dependent (RiftS == 80)=> figure out how to get this info at runtime
			OS.vsync_enabled = false;
	elif arvr_open_vr_interface:
		if arvr_open_vr_interface.initialize():
			get_viewport().arvr = true;
			Engine.target_fps = 90 # TODO: this is headset dependent => figure out how to get this info at runtime
			OS.vsync_enabled = false;
			vr_mode = true;	
	else:
		#Not running in VR / Demo mode
		cam.translation.y = 1.5
		cam.rotation.x = -0.4
		get_node("ARVROrigin/right_controller/AreaRight/DemoTimer").start()

	
	
	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	setup_globals()
	for i in range(200):
		player_height_stat.append(0)

	ball_l = get_node("ARVROrigin/left_controller/AreaLeft/handle_ball")
	var hand_l = get_node("ARVROrigin/left_controller/AreaLeft/Spatial")
	left_collision_root = get_node("ARVROrigin/left_controller/AreaLeft")
	
	ball_r = get_node("ARVROrigin/right_controller/AreaRight/handle_ball")
	var hand_r = get_node("ARVROrigin/right_controller/AreaRight/Spatial")
	right_collision_root = get_node("ARVROrigin/right_controller/AreaRight")
	
	left_controller = get_node("ARVROrigin/left_controller")
	right_controller = get_node("ARVROrigin/right_controller")
	
	#ball_l.hide()
	#ball_r.hide()
	
	initialize() #VR specific initialization
	
	if ovr_hand_tracking: 
		hand_l.hide()
		hand_r.hide()
		ovr_hand_tracking = ovr_hand_tracking.new()
		ball_l.show()
		ball_r.show()
	
	get_node("ARVROrigin/ARVRCamera").vr_mode = vr_mode
	levelselect = levelselect_blueprint.instance()
	add_child(levelselect)
	
	
func _on_level_finished	():
	print ("Level is finished ... remove from scene")
	var result = level.get_points()
	
	last_points = result["points"]
	total_points += result["points"]
	last_played = result["time"]
	total_played += result["time"]
	
	level.queue_free()
	level = null 
	levelselect = levelselect_blueprint.instance()
	add_child(levelselect)
	levelselect.set_main_text("Player results\n\nLast round\nPoints: %d"%last_points+" Duration: %.2f"%last_played+"\nTotal\nPoints: %d"%total_points+" Duration: %.2f"%total_played) 



var last_left_controller = [{"pos": Vector3(0,0,0), "ts": 0, "vector": Vector3(0,0,0)}]
var last_right_controller = [{"pos": Vector3(0,0,0), "ts": 0, "vector": Vector3(0,0,0)}]
var prediction_limit_ms = 200
var prediction_history_size = 10

func get_best_element_from_history(history, now, max_delta):
	var selected = 0
	for i in range(len(history)):
		if now - history[i]["ts"] > max_delta:
			break
		selected = i
	return history[selected]
	
func add_element_to_history(history, measurement):
	history.push_front(measurement)
	if len(history) > prediction_history_size:
		history.pop_back()			

#If the handtracking has lost the hand update the path for prediction_limt_ms before hiding it
func _update_hand_model(hand: ARVRController, model : Spatial, offset_model: Spatial, history):
	if ovr_hand_tracking: # check if the hand tracking API was loaded
		# scale of the hand model as reported by VrApi
		var ls = ovr_hand_tracking.get_hand_scale(hand.controller_id);
		var now = OS.get_ticks_msec()	
		var last = get_best_element_from_history(history, now, 150).duplicate()
				
		var delta_t = now - last["ts"]
		var confidence = ovr_hand_tracking.get_hand_pose(hand.controller_id, _vrapi_bone_orientations);
		if confidence > 0:
			hand.update_bone_orientations(_vrapi_bone_orientations, confidence)
			in_hand_mode = true
			if delta_t > prediction_limit_ms:
				#The last valid measurement is too old to get a valid vector
				#start from 0,0,0
				last["vector"] = Vector3(0,0,0)
			else:
				var delta = model.translation - last["pos"]
				last["vector"] = delta/delta_t
			last["ts"] = now
			last["pos"] = model.translation
			add_element_to_history(history, last)
			if not model.visible:
				model.show()
		elif model.visible and in_hand_mode:
			#print ("Prediction for Controller %d delta: %.3f"%[hand.controller_id, delta_t])
			if delta_t < prediction_limit_ms:
				model.translation = history[0]["pos"] + last["vector"] * delta_t
			else:
				model.hide()
		#print ("Confidence %.2f"%confidence)
#		model.rotation = offset_model.rotation
#		model.translation.x = -offset_model.translation.x
#		model.translation.y = -offset_model.translation.y
#		model.translation.z = -offset_model.translation.z
#
		return true;
	else:
		return false;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not vr_mode:
		if Input.is_key_pressed(KEY_P):
		    # start screen capture
		    var image = get_viewport().get_texture().get_data()
		    image.flip_y()
		    image.save_png("/tmp/vrworkout_screenshot_%d.png"%OS.get_ticks_msec())
	
	if level == null:
		player_height_stat[ clamp(int(100*cam.translation.y),0,len(player_height_stat)-1) ] += 1
		var v = 0
		for h in range(len(player_height_stat)):
			if player_height_stat[h] > v:
				v = player_height_stat[h]
				height = h/100.0
		#height = 0.98 * height + 0.02 * cam.translation.y
	else:
		if beast_mode:
			var tmp = level.beast_mode_supported()
			left_controller.set_beast_mode(tmp)
			right_controller.set_beast_mode(tmp)
			
		
	_update_hand_model(left_controller, left_collision_root, ball_l, last_left_controller);
	_update_hand_model(right_controller, right_collision_root, ball_r, last_right_controller);


func _on_Area_level_selected(num, diff):
	if level == null:
		set_beast_mode(ProjectSettings.get("game/beast_mode"))
		level = level_blueprint.instance()
		
		difficulty = diff
		level.song_index_parameter = num
		level.player_height = height
		level.bpm = levelselect.get_bpm()
		level.first_beat = levelselect.get_last_beat()
		level.setup_difficulty(difficulty)
		level.connect("level_finished",self,"_on_level_finished")
		levelselect.queue_free()
		add_child(level)	
	

func _on_Timer_timeout():
	_on_Area_level_selected(-1, 0)
	get_node("ARVROrigin/ARVRCamera").translation = Vector3(0,2,0.8)
	get_node("ARVROrigin/ARVRCamera/AreaHead/hit_player").play(0)
	print(get_node("ARVROrigin/ARVRCamera/AreaHead/hit_player").stream.get_length())

func get_running_speed():
	var s = get_node("ARVROrigin/ARVRCamera").get_running_speed()
	return s

	
func set_beast_mode(enabled):
	beast_mode = enabled
	ProjectSettings.set("game/beast_mode",enabled)
	left_controller.set_beast_mode(enabled)
	right_controller.set_beast_mode(enabled)
	
	
	
