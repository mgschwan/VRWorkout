extends Spatial

signal level_finished
var gu = GameUtilities.new()

var exercise_builder = preload("res://scripts/ExerciseBuilder.gd").new()
var stored
var CueState = GameVariables.CueState
var CueSelector = GameVariables.CueSelector

var exercise_state_model_template
var pushup_state_model
var squat_state_model
var stand_state_model_template
var stand_state_model

var rebalance_exercises = true

var song_index_parameter = 0
var audio_filename = ""

export var random_seed = true

var beats = []

var bpm = 60 #only used in freeplay mode
var first_beat = 0 #only used in freeplay mode
var beat_index = 0
var selected_song = 0
var stream

var player_height = 0
var run_point_multiplier = 1
var beast_mode = false
var kneesaver_mode = false
var song_current_bpm = 0

var ducking_mode = true

var target_hr = 140
var low_hr = 130
var high_hr = 150
var auto_difficulty = false
var avg_hr = 60	
	
var cue_streak = false
var hud_enabled = false	
	
var running_speed = 0
	
var next_exercise = CueState.STAND


var groove_display
var trophy_list


var cue_horiz = preload("res://cue_h_obj.tscn")
var cue_vert = preload("res://cue_v_obj.tscn")
var cue_head = preload("res://cue_head_obj.tscn")
var cue_head_avoid = preload("res://cue_head_obj_avoid.tscn")
var cue_highlight = preload("res://scenes/highlight_ring.tscn")
var environment = preload("res://outdoor_env.tres")
var infolayer

var cue_emitter
var target
var boxman1
var boxman2
	
var head_y_pos = 0

var rng = RandomNumberGenerator.new()

func display_state(state):
	var psign = get_node("PositionSign")
	if state == CueState.STAND:
		psign.stand()
	elif state == CueState.JUMP:
		psign.jump()
	elif state == CueState.SQUAT:
		psign.squat()
	elif state == CueState.PUSHUP:
		psign.pushup()
	elif state == CueState.CRUNCH:
		psign.crunch()
	elif state == CueState.BURPEE:
		psign.burpee() 
	elif state == CueState.SPRINT:
		psign.sprint() 
	elif state == CueState.YOGA:
		#TODO: Add sign
		pass
		
	
	get_node("ExerciseSelector").select(exercise_builder.state_string(state))
	
	
var update_counter = 0
func update_info(hits, max_hits, points):
	var song_pos = int(cue_emitter.current_playback_time)
	var total = int(stream.stream.get_length())
	
	var elapsed_string = gu.seconds_to_timestring(song_pos)
	
	infolayer.print_info("Hits %d/%d - Song: %s (%.1f%%) - Points: %d - Speed: %.1f"% [hits,max_hits,elapsed_string,float(100*song_pos)/total,points,running_speed])
	if update_counter % 5 == 0:
		infolayer.print_info("Player height: %.2f Difficulty: %.1f/%.2f/%.2f - E: %.2f"%[player_height, exercise_builder.current_difficulty, exercise_builder.min_cue_space, exercise_builder.min_state_duration,actual_state_duration], "debug")
	update_counter += 1
	infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE

func load_audio_resource(filename):
	var resource = null
	
	if filename.find("res://") == 0:
		resource = ResourceLoader.load(filename)
	else:
		var f = File.new()
		
		if  f.file_exists(filename):
			print ("External resource exists")
			f.open(filename, File.READ)
			var buffer = f.get_buffer(f.get_len())
			resource = AudioStreamOGGVorbis.new()
			resource.data = buffer
		else:
			print ("External resource does not exist")

	return resource

var last_update = 0
func _on_HeartRateData(hr):
	avg_hr = 0.33 * hr + 0.66  * avg_hr
	get_node("heart_coin").set_hr(hr)
	get_node("heart_coin").set_marker("actual", avg_hr)
	
	if auto_difficulty:
		var now = OS.get_ticks_msec()
		if now - last_update > 5000:
			exercise_builder.setup_difficulty(-1, true, avg_hr, target_hr)

func setup_game_data():
	GameVariables.level_statistics_data = {}
	auto_difficulty = GameVariables.auto_difficulty
	if len(GameVariables.exercise_state_list) > 0:
		exercise_builder.state_list = GameVariables.exercise_state_list	
	
	if ProjectSettings.get("game/exercise/strength_focus"):
		exercise_state_model_template = GameVariables.exercise_model["strength"]["exercise_state_model"]
		exercise_builder.pushup_state_model = GameVariables.exercise_model["strength"]["pushup_state_model"]
		exercise_builder.squat_state_model_template = GameVariables.exercise_model["strength"]["squat_state_model"]
		exercise_builder.stand_state_model_template = GameVariables.exercise_model["strength"]["stand_state_model"]
		exercise_builder.crunch_state_model  = GameVariables.exercise_model["strength"]["crunch_state_model"]
		exercise_builder.rebalance_exercises = GameVariables.exercise_model["strength"]["rebalance_exercises"]
	else:
		exercise_state_model_template = GameVariables.exercise_model["cardio"]["exercise_state_model"]
		exercise_builder.pushup_state_model = GameVariables.exercise_model["cardio"]["pushup_state_model"]
		exercise_builder.squat_state_model_template = GameVariables.exercise_model["cardio"]["squat_state_model"]
		exercise_builder.stand_state_model_template = GameVariables.exercise_model["cardio"]["stand_state_model"]
		exercise_builder.crunch_state_model  = GameVariables.exercise_model["cardio"]["crunch_state_model"]
		exercise_builder.rebalance_exercises = GameVariables.exercise_model["cardio"]["rebalance_exercises"]

	populate_state_model()
	
	beast_mode = ProjectSettings.get("game/beast_mode")
	exercise_builder.ducking_mode = ProjectSettings.get("game/exercise/duck")
	exercise_builder.kneesaver_mode = ProjectSettings.get("game/exercise/kneesaver")	
	target_hr = ProjectSettings.get("game/target_hr")	
	hud_enabled = ProjectSettings.get("game/hud_enabled")	

	low_hr = target_hr - 10
	high_hr = target_hr + 10

	exercise_builder.cue_emitter_state = get_start_exercise()
	exercise_builder.current_difficulty = GameVariables.difficulty
	exercise_builder.set_fly_distance( abs(cue_emitter.translation.z-target.translation.z) + 2, abs(cue_emitter.translation.z-target.translation.z) )


	exercise_builder.player_height = player_height
	exercise_builder.setup_difficulty(exercise_builder.current_difficulty)
	actual_game_state = exercise_builder.cue_emitter_state

	if GameVariables.game_mode == GameVariables.GameMode.STORED:
		print ("Load stored cues")
		exercise_builder.cue_emitter_list = GameVariables.cue_list.duplicate()
	GameVariables.cue_list.clear()


	internal_state_change()
	
	
	
		
	
func _ready():
	if random_seed:
		rng.randomize()
		exercise_builder.rng.randomize()
	else:
		rng.set_seed(0)
	GameVariables.reset_ingame_id()
	
	infolayer = get_node("Viewport/InfoLayer")
	cue_emitter = get_node("cue_emitter")
	target = get_node("target")
	
	boxman1 = get_node("boxman")
	boxman2 = get_node("boxman2")
	
	trophy_list = get_node("TrophyList")
	
	groove_display = get_node("GrooveDisplay")

	setup_game_data()

	get_tree().current_scene.set_detail_selection_mode(false)

	get_tree().get_current_scene().get_node("HeartRateReceiver").connect("heart_rate_received", self,"_on_HeartRateData")	
	
	#Set up the safe pushup view
	var mat = SpatialMaterial.new()
	mat.albedo_texture = get_tree().get_current_scene().get_node("PushupViewport").get_texture()
	mat.albedo_texture.flags = Texture.FLAG_FILTER
	mat.flags_unshaded = true
	get_node("PushupView").set_surface_material(0,mat)

	if not ProjectSettings.get("game/equalizer"):
		self.remove_child(get_node("SpectrumDisplay"))

	print ("Rebalance exercises: %s"%(str(rebalance_exercises)))

	get_node("heart_coin").set_marker("low", low_hr)
	get_node("heart_coin").set_marker("high", high_hr)
	
		
	beat_index = 0

	beats = []
	
	print ("Initializing AUDIO")
	print ("File: %s"%audio_filename)
	
	if song_index_parameter < 0:
		#freeplay mode
		stream = DummyAudioStream.new(abs(song_index_parameter)*100)
		selected_song = "Freeplay"
		print ("BPM %.2f"%bpm)
		stream.connect("stream_finished", self, "_on_AudioStreamPlayer_finished")
		self.add_child(stream)
	else:
		selected_song = audio_filename
				
		var beat_file = File.new()
		var error = beat_file.open("%s.json"%audio_filename, File.READ)
		beats = []
		
		if error == OK:
			var tmp = JSON.parse(beat_file.get_as_text()).result
			beat_file.close()
			beats = tmp.get("beats", [])
			print ("%d beats loaded"%len(beats))
		else: 
			print ("Could not open beat list")

		#var audio_file = File.new()
		
		infolayer.print_info("Loading song %s"%audio_filename)
		print ("Loading song: %s"%audio_filename)
		#error = audio_file.open(audio_filename,File.READ)
		#infolayer.append_info(" / File opened %s" % str(audio_file.is_open()))
		infolayer.print_info(exercise_builder.state_string(actual_game_state).to_upper(), "main")
		infolayer.print_info("Player height: %.2f Difficulty: %.2f/%.2f"%[player_height, exercise_builder.min_cue_space, exercise_builder.min_state_duration], "debug")
		infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
		var audio_resource = load_audio_resource(audio_filename)
		stream = get_node("AudioStreamPlayer")

		if audio_resource:
			stream.stream = audio_resource
		else:
			print ("Could not load audio")
			emit_signal("level_finished")	
	
	#If the song has no beats use the default beats
	if (GameVariables.override_beatmap or len(beats) == 0) and stream.stream:
		beats = []
		var delta = max(0.1, 60.0/float(max(1,bpm)))
		var now = OS.get_ticks_msec()	
		var pos = 0
		#get the correct starting time
		var elapsed = (now - first_beat)/1000.0
		pos =  (ceil(elapsed/delta) - elapsed/delta)*delta
		print ("Start at: %.2f"%pos)
				
		while pos < stream.stream.get_length()-delta:
			beats.append(pos)
			pos += delta

	if stream.stream:
		stream.play()
		
	update_safe_pushup()
	


func update_groove_iteration():
	if beat_index > 0:
		var beat_delta = beats[beat_index]-beats[beat_index-1]
		if beat_delta > 0:
			song_current_bpm = (3*song_current_bpm + 60/beat_delta)/4
	if beat_index % 2 == 0:
		if beat_index < len(beats)-2:
			groove_display.set_next_beat(beats[beat_index+2]-cue_emitter.current_playback_time, 1)
	groove_display.set_next_beat(beats[beat_index]-cue_emitter.current_playback_time, 0)	
	
func update_duration_indicator(progress):
	get_node("MeshInstance/DurationIndicator").scale.x = progress		

var last_beast_eval = 0	
func check_beast_status():
	var now = OS.get_ticks_msec()
	if now > last_beast_eval + exercise_builder.min_cue_space*1000:
		if exercise_builder.cue_emitter_state == CueState.STAND and beast_mode:
			if not boxman1.in_beast_mode and not boxman2.in_beast_mode:
				var beast_tmp = rng.randf()
				if beast_tmp < exercise_builder.beast_chance:
					var boxman = boxman1 
					if rng.randf() < 0.5:
						 boxman = boxman2
					boxman.activate_beast(Vector3(0,0,1),1.8)
		last_beast_eval = now	
		
var last_playback_time = 0
var last_game_update = 0
func _process(delta):
	#cue_emitter.current_playback_time += delta
	var sp = stream.get_playback_position()
	var gl = AudioServer.get_output_latency()
	var lm = AudioServer.get_time_since_last_mix()
	#That's a hack because get_time_since_last_mix() sometimes produces incorrect results (Godot 3.2.2)
	if lm > 0.1:
		lm = 0.0
	cue_emitter.current_playback_time = sp + lm - gl
	
	if beat_index < len(beats)-1 and cue_emitter.current_playback_time + exercise_builder.emit_early > beats[beat_index]:	
		update_groove_iteration()
		
		if GameVariables.game_mode == GameVariables.GameMode.STANDARD or GameVariables.game_mode == GameVariables.GameMode.EXERCISE_SET:
			exercise_builder.evaluate_beat(cue_emitter.current_playback_time, beats[beat_index])

		beat_index += 1
	elif beat_index == len(beats)-1:
		beat_index += 1
		infolayer.print_info("FINISHED", "main")
		infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE

	if cue_emitter.current_playback_time > last_game_update + 0.5:
		last_game_update = cue_emitter.current_playback_time
		if actual_game_state == CueState.SPRINT:
			handle_sprint_cues_actual(cue_emitter.current_playback_time)
		
		if actual_state_duration > 0:
			#print ("%s - %s / %s"%[str(cue_emitter.current_playback_time), str( actual_last_state_change), str( actual_state_duration ) ])
			update_duration_indicator( (cue_emitter.current_playback_time - actual_last_state_change) / actual_state_duration )
		else:
			#If no duration is set yet, setup the initial duration
			actual_state_duration = exercise_builder.state_duration

	create_all_current_cues( cue_emitter.current_playback_time )
	check_beast_status()
		
	if cue_emitter.current_playback_time < last_playback_time - 1.0 and stream.playing: 
		print ("Stop stream")
		stream.stop()
	
	#Current playback time could become negative which causes issues in other parts
	var tmp = max(0, cue_emitter.current_playback_time)	
	if tmp < 999999:
		last_playback_time = max(tmp, last_playback_time)
	
func _on_exit_timer_timeout():
	print ("End of level going back to main")
	emit_signal("level_finished")
	

func _on_tween_completed(obj,path):
	if obj.has_method("should_be_avoided") and obj.should_be_avoided():
		cue_emitter.score_avoided(obj)
	else:
		cue_emitter.score_miss(obj)
	obj.queue_free()

func switch_floor_sign_actual(type):
	var sign_node = get_node("FloorSign")
	if type == "hands":
		sign_node.show_feet(false)
		sign_node.show_hands(true)
	elif type == "feet":
		sign_node.show_hands(false)
		sign_node.show_feet(true)
	else:
		sign_node.show_hands(false)
		sign_node.show_feet(false)
		
func add_statistics_element(ingame_id, state_string, cue_type, difficulty, points, hit, starttime, targettime, hr):
	var statistics_element = {"e": state_string, "t": cue_type, "d": difficulty, "p": points, "h": hit, "st": starttime,"tt": targettime, "hr": hr}
	GameVariables.level_statistics_data [ingame_id] = statistics_element
	return ingame_id	


func create_all_current_cues(ts):
	while len(exercise_builder.cue_emitter_list) > 0 and ts > exercise_builder.cue_emitter_list[0][0]:
		var tmp = exercise_builder.cue_emitter_list.pop_front()
		
		#Store cue list for later replay
		GameVariables.cue_list.append(tmp) 
		
		var cue_data = tmp[1]
		if cue_data["cue_type"] == "state_change":
			print ("State change")
			update_sequence_results()
			actual_game_state = cue_data["state"]
			actual_state_duration = cue_data["state_duration"]
			actual_last_state_change = cue_emitter.current_playback_time
			internal_state_change()
			
		elif cue_data["cue_type"] == "floor_sign":
			switch_floor_sign_actual(cue_data["state"])
		else:
			var cue = create_and_attach_cue_actual(cue_data)
			if cue_data["target_cue"]:
				var target_cue = cue_emitter.get_cue_by_id(cue_data["target_cue"])
				if target_cue:
					cue.activate_path_cue(target_cue)
					pass
					
# Create the actual cue node add it to the scene and the statistics
func create_and_attach_cue_actual(cue_data):
	var cue_type = cue_data["cue_type"]
	var x = cue_data["x"]
	var y = cue_data["y"]
	var target_time = cue_data["target_time"]
	var fly_offset = cue_data["fly_offset"]
	var fly_time = cue_data["fly_time"]
	var cue_subtype = cue_data["cue_subtype"]
	var ingame_id = cue_data["ingame_id"]
	var hit_velocity = cue_data["hit_velocity"]
	var hit_score = cue_data["hit_score"]
	var fly_distance = cue_data.get("fly_distance", exercise_builder.fly_distance)
	
	var is_head = false
	var cue_node
	if cue_type == "right" or cue_type == "right_hold":
		cue_node = cue_horiz.instance()
	elif cue_type == "left" or cue_type == "left_hold":
		cue_node = cue_vert.instance()
	else:
		head_y_pos = y
		if cue_type == "head_avoid":
			is_head = true
			cue_node = cue_head_avoid.instance()
		else:
			is_head = true
			cue_node = cue_head.instance()
			if cue_type == "head_extended":
				cue_node.extended = true
	if cue_type in ["right_hold", "left_hold"]:
		cue_node.is_hold_cue = true
		cue_node.hold_time = 0.5
	cue_node.target_time = target_time
	cue_node.start_time = cue_emitter.current_playback_time
	var actual_flytime = fly_time
	if actual_flytime == 0:
		actual_flytime = exercise_builder.fly_time
	
	cue_node.hit_score = hit_score
	
	
	var main_node = get_node("cue_emitter")
	var move_modifier = Tween.new()
	move_modifier.set_name("tween")
	
	#If the player hits a streak of cues the next one will be special
	if cue_streak:
		cue_streak = false
		var highlight = cue_highlight.instance()
		highlight.get_node("AnimationPlayer").play("rotation")
		if is_head:
			highlight.scale = highlight.scale * 6
		cue_node.add_child(highlight)
		cue_node.point_multiplier = 3.0
	cue_node.add_child(move_modifier)
	main_node.add_child(cue_node)
	cue_node.translation = Vector3(x,y,0+fly_offset)
	
	if cue_type == "head_inverted":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3.1415926))
	elif cue_type == "head_left":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3.1415926/2))
	elif cue_type == "head_right":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3*3.1415926/2))
	
	if cue_type in ["left", "right", "left_hold", "right_hold"]:
		var alpha = atan2(x,y-head_y_pos)
		cue_node.set_transform(cue_node.get_transform().rotated(Vector3(0,0,1),-alpha))
		
	if hit_velocity != null:
		cue_node.velocity_required = hit_velocity

	#Heartrate is stored with the start of the cue because that's the only definitive timestamp we know
	add_statistics_element(ingame_id, exercise_builder.state_string(actual_game_state)+"/%s"%cue_subtype, cue_type, exercise_builder.current_difficulty, 0, false, cue_emitter.current_playback_time, target_time, GameVariables.current_hr)
	cue_node.ingame_id = ingame_id
	
	move_modifier.interpolate_property(cue_node,"translation",Vector3(x,y,0+fly_offset),Vector3(x,y,fly_distance+fly_offset),actual_flytime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	move_modifier.connect("tween_completed",self,"_on_tween_completed")
	move_modifier.start()
	return cue_node

	

func get_start_exercise():
	var retVal = CueState.STAND
	
	if len(exercise_builder.state_list) > 0:
		retVal = exercise_builder.string_to_state(exercise_builder.get_current_state_from_list())
		exercise_builder.state_duration = exercise_builder.get_current_duration_from_list()
		actual_game_state = retVal
		actual_state_duration = exercise_builder.state_duration
		exercise_builder.min_state_duration = exercise_builder.state_duration
		print ("Using preset workout  %s/%s"%[exercise_builder.cue_emitter_state,exercise_builder.state_duration])

	else:
		var states = { 	CueState.STAND  : ProjectSettings.get("game/exercise/stand"),
						CueState.SQUAT  : ProjectSettings.get("game/exercise/squat"),
						CueState.PUSHUP  : ProjectSettings.get("game/exercise/pushup"),
						CueState.CRUNCH  : ProjectSettings.get("game/exercise/crunch"),
						CueState.JUMP  : ProjectSettings.get("game/exercise/jump"),
						CueState.BURPEE  : ProjectSettings.get("game/exercise/burpees"),
						CueState.SPRINT  : ProjectSettings.get("game/exercise/sprint"),
						CueState.YOGA  : ProjectSettings.get("game/exercise/yoga"),
					}
		for key in states:
			if states[key]:
				retVal = key
				break
	return retVal


func populate_state_model():
	exercise_builder.exercise_state_model.clear()
	var states = { 	CueState.STAND  : ProjectSettings.get("game/exercise/stand"),
					CueState.SQUAT  : ProjectSettings.get("game/exercise/squat"),
					CueState.PUSHUP  : ProjectSettings.get("game/exercise/pushup"),
					CueState.CRUNCH  : ProjectSettings.get("game/exercise/crunch"),
					CueState.JUMP  : ProjectSettings.get("game/exercise/jump"),
					CueState.BURPEE  : ProjectSettings.get("game/exercise/burpees"),
					CueState.SPRINT  : ProjectSettings.get("game/exercise/sprint"),
					CueState.YOGA  : ProjectSettings.get("game/exercise/yoga"),
				}
				
	for key in states:
		exercise_builder.exercise_state_model[key] = {}
		for key_2 in states:
			if exercise_state_model_template[key].has(key_2):
				var val = exercise_state_model_template[key][key_2]
				if key != key_2 and states[key_2]:
					exercise_builder.exercise_state_model[key][key_2] = val
	print (str(exercise_builder.exercise_state_model))
	
	exercise_builder.stand_state_model = exercise_builder.stand_state_model_template.duplicate(true)
	
	
var sprint_multiplier = 10.0
var last_sprint_update = 0
func handle_sprint_cues_actual(target_time):
	switch_floor_sign_actual("feet")
	var now = OS.get_ticks_msec()
	var delta = now - last_sprint_update
	var points = sprint_multiplier * running_speed * delta / 1000.0
	last_sprint_update = now
	var ingame_id = add_statistics_element(GameVariables.get_next_ingame_id(), exercise_builder.state_string(exercise_builder.cue_emitter_state), "", exercise_builder.current_difficulty, points, true, cue_emitter.current_playback_time, cue_emitter.current_playback_time, GameVariables.current_hr)
	cue_emitter.score_points(points)

var actual_game_state  
var actual_state_duration = 0
var actual_last_state_change = 0
func internal_state_change():
	if actual_game_state != CueState.SPRINT:
		get_tree().current_scene.set_controller_visible(true)
		
	if actual_game_state == CueState.BURPEE or actual_game_state == CueState.PUSHUP:
			update_safe_pushup()	
		
	infolayer.print_info(exercise_builder.state_string(actual_game_state).to_upper(), "main")
	infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
	get_node("PositionSign").start_sign(cue_emitter.translation, get_node("target").translation, exercise_builder.emit_early)
	if not boxman1.in_beast_mode:
		switch_boxman(actual_game_state,"boxman")
	if not boxman2.in_beast_mode:
		switch_boxman(actual_game_state,"boxman2")
	display_state(actual_game_state)

		
func update_safe_pushup():
	if hud_enabled:
		var main_camera = get_viewport().get_camera()
		if actual_game_state == CueState.BURPEE or actual_game_state == CueState.PUSHUP:
			main_camera.show_hud(true)
			get_node("MainStage/mat").open_mat()
		else:
			get_node("MainStage/mat").close_mat()
			main_camera.show_hud(false)
		
func switch_boxman(state, name):
	var boxman = get_node(name)
	if state == CueState.STAND:
		if name == "boxman2":
			boxman.switch_to_run()
		else:
			boxman.switch_to_stand()
	elif state == CueState.JUMP:
		boxman.switch_to_jumping()
	elif state == CueState.SQUAT:
		boxman.switch_to_squat()
	elif state == CueState.CRUNCH:
		boxman.switch_to_situps()
	elif state == CueState.PUSHUP:
		boxman.switch_to_plank()
	elif state == CueState.BURPEE:
		boxman.switch_to_plank() #TODO make a burpee animation
	elif state == CueState.SPRINT:
		boxman.switch_to_run() 


func _on_exit_button_pressed():
	emit_signal("level_finished")

var last_run_update = 0		
func setup_multiplier(running_speed):
	var xx = get_node("RunIndicator")
	if running_speed > 13.5:
		xx.play("hyperspeed")
		run_point_multiplier = 4
	elif running_speed > 10:
		xx.play("runx3")
		run_point_multiplier = 3
	elif running_speed > 7:
		xx.play("runx2")
		run_point_multiplier = 2
	else:
		xx.stop()
		run_point_multiplier = 1

	var now = OS.get_ticks_msec()
	var delta = (now-last_run_update)/1000.0
	if last_run_update > 0 and run_point_multiplier > 1:
		trophy_list.set_runtime(trophy_list.runtime + delta)
	last_run_update = now


func get_points():
	var vrw_score = 0
	if cue_emitter.max_hits > 0:
		vrw_score = 100.0 *cue_emitter.hits/cue_emitter.max_hits
	return {"points": cue_emitter.points, "vrw_score": vrw_score, "hits": cue_emitter.hits, "max_hits": cue_emitter.max_hits,"time": last_playback_time}

var last_grooove_update = 0
func update_groove(groove_bpm):
	var now = OS.get_ticks_msec()
	var delta = (now - last_grooove_update)/1000.0
	if last_grooove_update > 0:
		if groove_bpm > 0:
			var multiplier = song_current_bpm / groove_bpm
			#print ("Current_bpm: %f Song BPM: %f  Mult: %f"%[groove_bpm, song_current_bpm, multiplier])
			if abs(multiplier-1) < 0.15 or abs(multiplier-2) < 0.2 or abs(multiplier-4) < 0.3:
				#Groove detected
				trophy_list.set_groovetime(trophy_list.groove + delta)
	last_grooove_update = now	

var gui_update = 0
func _on_UpdateTimer_timeout():
	running_speed = self.get_parent().get_running_speed()
	var gauge = get_node("rungauge")
	if actual_game_state != CueState.SPRINT and gauge.value_text:
			gauge.hide()

	gauge.set_value(running_speed)
	update_groove(self.get_parent().get_groove_bpm())
	setup_multiplier(running_speed)
	if gui_update % 10 == 0:
		self.update_info(cue_emitter.hits, cue_emitter.max_hits, cue_emitter.points)
	gui_update += 1


func _on_AudioStreamPlayer_finished():
	stream.stop()
	var t = Timer.new()
	t.connect("timeout", self, "_on_exit_timer_timeout")
	t.set_wait_time(5)
	self.add_child(t)
	t.start()

#Returns true if the current state supports claws
func beast_mode_supported():
	return exercise_builder.cue_emitter_state == CueState.STAND or boxman1.in_beast_mode or boxman2.in_beast_mode

func _on_boxman_beast_attack_successful():
	cue_emitter.score_negative_hits(10)


func _on_boxman_beast_killed():
	cue_emitter.score_positive_hits(10)


func _on_ExerciseSelector_selected(type):
	exercise_builder.cue_emitter_state = exercise_builder.string_to_state(type)
	exercise_builder.builder_state_changed(cue_emitter.current_playback_time)
	#internal_state_change()

func update_sequence_results():
	var last_score = cue_emitter.get_hit_score()
	var last_success_rate = cue_emitter.get_success_rate()
		
	cue_emitter.reset_current_points()


func _on_PositionSign_state_change_completed():
	update_safe_pushup()
	var gauge = get_node("rungauge")
	if actual_game_state == CueState.SPRINT and not gauge.visible:
		gauge.show()
		get_tree().current_scene.set_controller_visible(false)


		
var auto_hit_distance = 0.3
func controller_tracking_lost(controller):
	var node = cue_emitter.get_closest_cue(controller.global_transform.origin, "hand", controller.is_left)
	print ("Tracking lost. Closest object: %s"%str(node))
	if node:
		if node.global_transform.origin.distance_to(controller.global_transform.origin) < auto_hit_distance:
			var type = "right"
			if controller.is_left:
				type = "left"
				
			node.has_been_hit(type)
	
func controller_tracking_regained(controller):
	var node = cue_emitter.get_closest_cue(controller.global_transform.origin, "hand", controller.is_left)
	print ("Tracking regained. Closest object: %s"%str(node))

	if node:
		if node.global_transform.origin.distance_to(controller.global_transform.origin) < auto_hit_distance:
			var type = "right"
			if controller.is_left:
				type = "left"
				
			node.has_been_hit(type)
		


func play_encouragement():
	var selector = rng.randi()%5
	if selector == 0:
		get_node("VoiceInstructor").say("keep it up")
	elif selector == 1:
		get_node("VoiceInstructor").say("go go go")
	elif selector == 2:
		get_node("VoiceInstructor").say("go for it")
	elif selector == 3:
		get_node("VoiceInstructor").say("thats the spirit")
	elif selector == 4:
		get_node("VoiceInstructor").say("you are on a roll")
	

func _on_cue_emitter_streak_changed(count):
	if count > 0 and count % 15 == 0:
		cue_streak = true
	if count == 15:
		if actual_game_state == CueState.SPRINT:
			if run_point_multiplier >= 3:
				play_encouragement()
			else:
				get_node("VoiceInstructor").say("faster")
		else:					
			play_encouragement()
