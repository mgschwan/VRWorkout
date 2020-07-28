extends Spatial

var level_blueprint = null 
var levelselect_blueprint = null  
var splashscreen = preload("res://Splashscreen.tscn").instance()
var left_controller_blueprint = preload("res://Left_Controller_Tree.tscn")
var right_controller_blueprint = preload("res://Right_Controller_Tree.tscn")
var blue_environment = null 
var red_environment = null 



var gu = GameUtilities.new()


var levelselect
var level = null
var cam = null

var vr_mode = true
var beast_mode = false
export var record_tracker_data = false

var arvr_interface = null
var screen_tint_node


var left_controller
var right_controller
var left_collision_root
var right_collision_root

var in_hand_mode = false #auto detect hand_mode, can't revert back automatically


var tracking_data = []


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

func handle_mobile_permissions():
	#TODO Request permissions for external storage
	print ("Checking permissions")
	var perm = OS.get_granted_permissions()
	var read_storage_perm = false
	var write_storage_perm = false
	
	for p in perm:
		print ("Permissions %s already granted"%p)
		if p == "android.permission.READ_EXTERNAL_STORAGE":
			read_storage_perm = true
		elif p == "android.permission.WRITE_EXTERNAL_STORAGE":
			write_storage_perm = true
	
	if not (read_storage_perm and write_storage_perm):
		print ("Requesting permissions")
		OS.request_permissions()

func _on_Controller_Tracking_Lost(controller):
	if level != null:
		level.controller_tracking_lost(controller)
	
func _on_Controller_Tracking_Regained(controller):
	if level != null:
		level.controller_tracking_regained(controller)

func _on_Tracker_removed(tracker_name, type, id):
	print ("Tracker removed: %s / %d / %d"%[tracker_name, type, id])	

	for t in GameVariables.trackers:
		if t.controller_id == id:
			GameVariables.trackers.erase(t)
			t.queue_free()
			break
			
func _on_Tracker_added(tracker_name, type, id):
	print ("Tracker added: %s / %d / %d"%[tracker_name, type, id])	
	
	if type == ARVRServer.TRACKER_CONTROLLER:
		print ("New controller added %s"%tracker_name.to_lower())
			
		var controller = ARVRController.new()
		controller.controller_id = id
		
		var is_left = false
		if controller.get_hand() == ARVRPositionalTracker.TRACKER_LEFT_HAND:
			is_left = true
		elif controller.get_hand() == ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:	
			#If the tracker can't be identified by the API try to identify it by name
			is_left = (tracker_name.to_lower()).find("left") >= 0
			var is_right = (tracker_name.to_lower()).find("right") >= 0
			
			#If there are trackers that can't be identified make sure that at least
			#one of them is assigned to left
			if not is_left and not is_right:
				for t in GameVariables.trackers:
					if t.get_hand() == ARVRPositionalTracker.TRACKER_HAND_UNKNOWN:
						if t.is_left == false:
							is_left = true
							break
			
		controller.queue_free()
			
		#TODO: Make the controller universal without needing a left and right controller scene	
		var new_controller = null		
		if is_left:
			print ("Left controller")
			new_controller = left_controller_blueprint.instance()
			new_controller.is_left = true
		else:			
			print ("Right controller")	
			new_controller = right_controller_blueprint.instance()
			new_controller.is_left = false

		new_controller.controller_id = id
		get_node("ARVROrigin").add_child(new_controller)
		new_controller.set_detail_select(GameVariables.detail_selection_mode)
		GameVariables.trackers.append(new_controller)



			
func set_detail_selection_mode(value):
	GameVariables.detail_selection_mode = value
	for t in GameVariables.trackers:
		if t:
			print ("Set tracker detail (%s): %s"%[str(t),str(value)])
			t.set_detail_select(value)

func initialize():
	var arvr_ovr_mobile_interface = ARVRServer.find_interface("OVRMobile");
	var arvr_oculus_interface = ARVRServer.find_interface("Oculus");
	var arvr_open_vr_interface = ARVRServer.find_interface("OpenVR");

	ARVRServer.connect("tracker_added",self,"_on_Tracker_added")
	ARVRServer.connect("tracker_removed",self, "_on_Tracker_removed")

	vr_mode = false
	cam = get_node("ARVROrigin/ARVRCamera")


	ProjectSettings.set("game/external_songs", ProjectSettings.get("application/config/pc_music_directory"))
	print (ProjectSettings.get("game/external_songs"))

	if arvr_ovr_mobile_interface:
		ProjectSettings.set("game/is_oculusquest", true)
		ProjectSettings.set("game/external_songs", ProjectSettings.get("application/config/music_directory"))
		

		handle_mobile_permissions()

		# the init config needs to be done before arvr_interface.initialize()
		ovr_init_config = load("res://addons/godot_ovrmobile/OvrInitConfig.gdns");
		if (ovr_init_config):
			ovr_init_config = ovr_init_config.new()
			ovr_init_config.set_render_target_size_multiplier(1) # setting to 1 here is the default
		
		if arvr_ovr_mobile_interface.initialize():
			arvr_interface = arvr_ovr_mobile_interface
			get_viewport().arvr = true
			get_viewport().hdr = false
			OS.vsync_enabled = false
			#Test: Video recording on the Quest is stuttering, I read somewhere
			#that this is because of th FPS not being a multiple of 30
			# deactivated for now # #Engine.target_fps = 72 
			_initialize_OVR_API()
			vr_mode = true
		
	elif arvr_oculus_interface:
		if arvr_oculus_interface.initialize():
			arvr_interface = arvr_oculus_interface
			vr_mode = true
			get_viewport().arvr = true;
			Engine.target_fps = 80 # TODO: this is headset dependent (RiftS == 80)=> figure out how to get this info at runtime
			OS.vsync_enabled = false;
	elif arvr_open_vr_interface:
		if arvr_open_vr_interface.initialize():
			arvr_interface = arvr_open_vr_interface
			get_viewport().arvr = true;
			Engine.target_fps = 90 # TODO: this is headset dependent => figure out how to get this info at runtime
			OS.vsync_enabled = false;
			vr_mode = true;	
	else:
		#Not running in VR / Demo mode
		cam.translation.y = 1.5
		cam.rotation.x = -0.4
		

# Called when the node enters the scene tree for the first time.
func _ready():
	GameVariables.device_id = str(gu.get_device_id())
	
	print ("Unique device id %s"%GameVariables.device_id)
	GameVariables.setup_globals()
	initialize() #VR specific initialization

	screen_tint_node = get_node("ARVROrigin/ARVRCamera/ScreenTint")
	splashscreen.head_node = get_node("ARVROrigin/ARVRCamera")
	splashscreen.connect("splash_screen_finished", self,"_on_Splashscreen_finished")
	add_child(splashscreen)
	
	
	if ovr_hand_tracking: 
		ovr_hand_tracking = ovr_hand_tracking.new()
	
	get_node("ARVROrigin/ARVRCamera").vr_mode = vr_mode
	
	
	level_blueprint = preload("res://Level.tscn")
	levelselect_blueprint = preload("res://Levelselect.tscn")
	if not vr_mode:
		_on_Tracker_added("right", ARVRServer.TRACKER_CONTROLLER, 1)
		GameVariables.trackers[0].translation.y = 1.5
		
func _on_level_finished	():
	get_viewport().get_camera().blackout_screen(true)
	get_viewport().get_camera().show_hud(false)
	
	if record_tracker_data:
		print ("Storing tracker data")
		var f = File.new()
		f.open("user://tracker.data", File.WRITE)
		f.store_var(tracking_data)
		f.close()
		tracking_data.clear()	
	
	print ("Level is finished ... remove from scene")
	var result = level.get_points()
	
	last_points = result["points"]
	total_points += result["points"]
	last_played = result["time"]
	total_played += result["time"]
	
	get_node("RemoteInterface").send_data(GameVariables.device_id, "workout", {"api_version": GameVariables.api_version, "score": result["points"], "duration": result["time"] , "data":GameVariables.level_statistics_data})

	
	level.queue_free()
	level = null 
	levelselect = levelselect_blueprint.instance()
	levelselect.translation = Vector3(0,0,0)
	levelselect.connect("level_selected",self,"_on_Area_level_selected")

	add_child(levelselect)
	
	
	var last_played_str = gu.seconds_to_timestring(last_played)
	var total_played_str = gu.seconds_to_timestring(total_played)
	
	levelselect.set_main_text("Player results\n\nLast round\nPoints: %d"%last_points+" Duration: %s"%last_played_str+"\nTotal\nPoints: %d"%total_points+" Duration: %s"%total_played_str) 

	yield(get_tree().create_timer(1), "timeout")
	get_viewport().get_camera().blackout_screen(false)


var prediction_limit_ms = 200
var prediction_history_size = 10
var prediction_max_dist = 0.2

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

var hand_ball_adjusted = false

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
			
			if hand.tracking_lost:
				_on_Controller_Tracking_Regained(hand)
				hand.tracking_lost = false

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
			if not hand.tracking_lost:
				_on_Controller_Tracking_Lost(hand)
				hand.tracking_lost = true
			if delta_t < prediction_limit_ms:
				var vec = last["vector"]
				var predict_v = vec * delta_t / prediction_max_dist
				var vl = predict_v.length()
				if vl > prediction_max_dist:
					predict_v = prediction_max_dist * predict_v / vl
				model.translation = history[0]["pos"] + predict_v 
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
	
	if level != null:
		if beast_mode:
			var tmp = level.beast_mode_supported()
			for t in GameVariables.trackers:
				if t:
					t.set_beast_mode(tmp)
	
	for t in GameVariables.trackers:
		if t:	
			_update_hand_model(t, t.collision_root, t.model, t.last_controller);

	#if record_tracker_data and left_controller and right_controller:
	#	tracking_data.append([OS.get_ticks_msec(), cam.translation, cam.rotation,left_controller.translation,left_controller.rotation,right_controller.translation, right_controller.rotation])


func _on_Area_level_selected(filename, diff, num):
	if level == null:
		set_beast_mode(ProjectSettings.get("game/beast_mode"))
		level = level_blueprint.instance()
		
		GameVariables.override_beatmap = false
		if diff == 3:
			GameVariables.override_beatmap = true

		GameVariables.difficulty = diff
		
		level.audio_filename = filename
		level.song_index_parameter = num
		level.player_height = ProjectSettings.get("game/player_height")
		level.bpm = ProjectSettings.get("game/bpm")
		level.first_beat = levelselect.get_last_beat()
		level.connect("level_finished",self,"_on_level_finished")
		levelselect.queue_free()
		add_child(level)	
	

func _on_DemoTimer_timeout():
	#levelselect.get_node("SettingsCarousel/Connections/VRHealthConnection").connect_vrhealth()
	#get_node("RemoteInterface").send_data(GameVariables.device_id, "exercise", {"test":"12345678"})
	change_environment("angry")
	#levelselect.get_node("SettingsCarousel/Connections/VRWorkoutConnection").connect_vrworkout()
	#GameVariables.exercise_state_list = GameVariables.predefined_exercises["Low pyramid"]
	#_on_Area_level_selected("res://audio/songs/01_VRWorkout.ogg", 0, 1)
	
	_on_Area_level_selected("res://audio/songs/Z_120BPM_Test.ogg", 2, 1)
	#_on_Area_level_selected("res://home/developer/Music/Workout/mono.ogg", 2, 1)
	get_node("ARVROrigin/ARVRCamera").translation = Vector3(0,2,0.8)
	get_node("ARVROrigin/ARVRCamera/AreaHead/hit_player").play(0)
	print(get_node("ARVROrigin/ARVRCamera/AreaHead/hit_player").stream.get_length())

func get_running_speed():
	var s = get_node("ARVROrigin/ARVRCamera").get_running_speed()
	return s

func get_groove_bpm():
	var s = get_node("ARVROrigin/ARVRCamera").get_groove_bpm()
	return s

	
func set_beast_mode(enabled):
	beast_mode = enabled
	ProjectSettings.set("game/beast_mode",enabled)
	for t in GameVariables.trackers:
		if t:
			t.set_beast_mode(enabled)

func _on_Splashscreen_finished():
	get_viewport().get_camera().blackout_screen(true)
	
	
	red_environment = load("res://default_env_red.tres")
	blue_environment = load("res://default_env.tres")

	levelselect = levelselect_blueprint.instance()
	levelselect.translation = Vector3(0,0,0)
	levelselect.connect("level_selected",self,"_on_Area_level_selected")


	splashscreen.queue_free()
	add_child(levelselect)
	if not vr_mode:
		get_node("DemoTimer").start()


func change_environment(value):
	if value == "angry":
		get_viewport().get_camera().environment = red_environment
	else:
		get_viewport().get_camera().environment = blue_environment




