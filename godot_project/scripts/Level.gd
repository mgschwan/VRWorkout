extends Spatial

signal level_finished
signal level_finished_manually


signal set_exercise(exercise)
signal update_user_points(userid, points, rank)

var gu = GameUtilities.new()

var exercise_builder = preload("res://scripts/ExerciseBuilder.gd").new()
var stored
var CueState = GameVariables.CueState
var CueSelector = GameVariables.CueSelector

var game_state = GameSyncSate.INIT


onready var battle_module

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
var cue_squat_avoid = preload("res://scenes/SquatAvoidCue.tscn")
var cue_avoid_bar = preload("res://scenes/ParcourAvoidCue.tscn")
var cue_highlight = preload("res://scenes/highlight_ring.tscn")
var cue_weight = preload("res://scenes/WeightCue.tscn")
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
	elif state == CueState.WEIGHTS:
		psign.weights() 
	elif state == CueState.YOGA:
		#TODO: Add sign
		pass
			
	
var update_counter = 0
func update_info(hits, max_hits, points):
	var song_pos = int(cue_emitter.current_playback_time)
	var total = max(1.0, int(stream.stream.get_length())) #max(1.0,val) to prevent divison by zero

	$TrophyList.set_score(0,"Player", hits, points) 
	
	var elapsed_string = gu.seconds_to_timestring(song_pos)
	var t = OS.get_time()	
	infolayer.print_info("Hits %d/%d - Song: %s (%.1f%%) - P: %d"% [hits,max_hits,elapsed_string,float(100*song_pos)/total,points])
	if update_counter % 5 == 0:
		infolayer.print_info("Difficulty: %.1f/%.2f/%.2f - E: %.2f - H: %.2f - Clock: %02d:%02d"%[exercise_builder.current_difficulty, exercise_builder.min_cue_space, exercise_builder.min_state_duration,actual_state_duration,GameVariables.player_height, t["hour"],t["minute"]], "debug")
	update_counter += 1
	infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE


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

	var dynamic_states = true

	if len(GameVariables.exercise_state_list) > 0:
		dynamic_states = false
		exercise_builder.state_list = GameVariables.exercise_state_list	
	
	if ProjectSettings.get("game/exercise/strength_focus"):
		exercise_state_model_template = GameVariables.exercise_model["strength"]["exercise_state_model"]
		exercise_builder.pushup_state_model_template = GameVariables.exercise_model["strength"]["pushup_state_model"]
		exercise_builder.squat_state_model_template = GameVariables.exercise_model["strength"]["squat_state_model"]
		exercise_builder.stand_state_model_template = GameVariables.exercise_model["strength"]["stand_state_model"]
		exercise_builder.crunch_state_model  = GameVariables.exercise_model["strength"]["crunch_state_model"]
		exercise_builder.rebalance_exercises = GameVariables.exercise_model["strength"]["rebalance_exercises"]
	else:
		exercise_state_model_template = GameVariables.exercise_model["cardio"]["exercise_state_model"]
		exercise_builder.pushup_state_model_template = GameVariables.exercise_model["cardio"]["pushup_state_model"]
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


	exercise_builder.player_height = GameVariables.player_height
	exercise_builder.setup_difficulty(exercise_builder.current_difficulty)
	actual_game_state = exercise_builder.cue_emitter_state


	if GameVariables.game_mode == GameVariables.GameMode.STORED:
		print ("Load stored cues")
		exercise_builder.cue_emitter_list = GameVariables.cue_list.duplicate()
		dynamic_states = false
	GameVariables.cue_list.clear()

	cue_emitter.connect("hit_scored", self, "_on_cue_hit_scored")


	if GameVariables.battle_mode != GameVariables.BattleMode.NO:
		battle_module = load("res://scenes/BattleDisplay.tscn").instance()
		battle_module.name = "BattleDisplay"
		add_child(battle_module)
		battle_module.connect("player_won",self,"_on_BattleDisplay_player_won")

		cue_emitter.connect("hit_scored", battle_module, "hit_scored")
		cue_emitter.connect("update_info", self, "update_info")

		self.connect("set_exercise", battle_module, "set_exercise")
		gu.deactivate_node(boxman1)
		gu.deactivate_node(boxman2)	

		
		if GameVariables.battle_team == GameVariables.BattleTeam.RED:
			get_node("MainStage/blue_outdoor_stage").set_color("red")
			battle_module.set_player_teams(GameVariables.BattleTeam.RED,GameVariables.BattleTeam.BLUE)
		else:
			get_node("MainStage/blue_outdoor_stage").set_color("blue")
			battle_module.set_player_teams(GameVariables.BattleTeam.BLUE,GameVariables.BattleTeam.RED)
	else:
		gu.activate_node(boxman1)
		gu.activate_node(boxman2)	

	if not dynamic_states:
		print ("States are not dynamic and can't be skipped")
		get_node("SkipExerciseButton").queue_free()


		
	internal_state_change()

		
var player_head
#var spectator_cam
func _ready():
	if GameVariables.ar_mode:
		gu.deactivate_node(get_node("MainStage/blue_outdoor_stage"))
	
	if not GameVariables.vr_mode:
		player_head =  Spatial.new()  #load("res://scenes/PlayerHead.tscn").instance()
		add_child(player_head)

		#spectator_cam = Camera.new()
		#spectator_cam.far = 300
		#add_child(spectator_cam)
		#spectator_cam.current = true
	
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
	#var mat = SpatialMaterial.new()
	#mat.albedo_texture = get_tree().get_current_scene().get_node("PushupViewport").get_texture()
	#mat.albedo_texture.flags = Texture.FLAG_FILTER
	#mat.flags_unshaded = true
	#get_node("PushupView").set_surface_material(0,mat)

	if not ProjectSettings.get("game/equalizer"):
		self.remove_child(get_node("SpectrumDisplay"))

	#print ("Rebalance exercises: %s"%(str(rebalance_exercises)))

	get_node("heart_coin").set_marker("low", low_hr)
	get_node("heart_coin").set_marker("high", high_hr)
	
		
	beat_index = 0

	beats = []
	
	print ("Initializing AUDIO")
	print ("File: %s"%str(audio_filename))
	
	selected_song = audio_filename
	
	infolayer.print_info("Loading songs %s"%str(audio_filename))
	print ("Loading song: %s"%(str(audio_filename)))
	infolayer.print_info(exercise_builder.state_string(actual_game_state).to_upper(), "main")
	infolayer.print_info("Player height: %.2f Difficulty: %.2f/%.2f"%[GameVariables.player_height, exercise_builder.min_cue_space, exercise_builder.min_state_duration], "debug")
	infolayer.get_parent().render_target_update_mode = Viewport.UPDATE_ONCE
	
	stream = AudioStreamPlaylist.new(audio_filename,get_tree().current_scene)
	stream.connect("stream_finished",self,"_on_AudioStreamPlayer_finished")
	add_child(stream)
	beats = stream.playlist_beats		
	
	if stream.stream:
		if GameVariables.battle_mode != GameVariables.BattleMode.NO:
			get_node("BattleDisplay").setup_data(int(stream.stream.get_length()))
			
	update_safe_pushup()
	
	#Setup the ghost if available
	if len(GameVariables.input_level_statistics_data):
		add_remote_user_messages("Ghost", GameVariables.input_level_statistics_data, 1)
	GameVariables.input_level_statistics_data = Dictionary()

	if not (GameVariables.multiplayer_api and GameVariables.multiplayer_api.is_multiplayer()):
		game_state = GameSyncSate.LEVEL_BEGIN

	GameVariables.vr_camera.blackout_screen(false)


#Used for multiplayer to prepopulate the exercises on all players
func prebuild_exercise_list():
	for beat in range(len(beats)):
		var target_time = beats[beat]
		var start_time = max(0,beats[beat] - exercise_builder.emit_early)
		if GameVariables.game_mode == GameVariables.GameMode.STANDARD or GameVariables.game_mode == GameVariables.GameMode.EXERCISE_SET:
			exercise_builder.evaluate_beat(start_time, target_time)


enum GameSyncSate {
	INIT = 0,
	LEVEL_WAIT_BEGIN = 1,
	LEVEL_BEGIN = 2,
	LEVEL_RUNNING = 3,
}	
	
func game_start_checkpoint():
	if GameVariables.multiplayer_api:	
		if game_state == GameSyncSate.INIT:
			if  GameVariables.multiplayer_api.is_multiplayer_host():	
				if GameVariables.game_mode != GameVariables.GameMode.STORED:
					prebuild_exercise_list()
								
				GameVariables.multiplayer_api.send_game_message({"type":"start","exercise_list": exercise_builder.cue_emitter_list})
				
				game_state = GameSyncSate.LEVEL_WAIT_BEGIN
			
			elif GameVariables.multiplayer_api.is_multiplayer_client():
				GameVariables.multiplayer_api.send_game_message({"type":"level_begin"})
			
				game_state = GameSyncSate.LEVEL_BEGIN

	if game_state == GameSyncSate.LEVEL_BEGIN and stream.stream:
		game_state = GameSyncSate.LEVEL_RUNNING
		stream.play()	
	
func _on_multiplayer_game_message(sender, message):
	var message_type = message.get("type","")
	#print ("Level game_message received %s"%str(message))
	if message_type == "level_begin" and game_state == GameSyncSate.LEVEL_WAIT_BEGIN:
		game_state = GameSyncSate.LEVEL_BEGIN
	elif message_type == "remote_statistics_data":
		if not GameVariables.multiplayer_api.is_self_user(sender):
			var statistics = message.get("statistics",[])
			add_remote_user_messages(GameVariables.multiplayer_api.get_player_name(sender), statistics, sender)

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
var last_battle_update = 0

func _process(delta):
	if game_state != GameSyncSate.LEVEL_RUNNING:
		game_start_checkpoint()
	
	if not GameVariables.vr_mode:
		var c = get_viewport().get_camera()
		#c.translation = GameVariables.vr_camera.translation + Vector3(0,0,1.0)
		player_head.global_transform = GameVariables.vr_camera.global_transform
		
		#spectator_cam.global_transform = player_head.global_transform
		#spectator_cam.global_transform.basis = Basis.IDENTITY
		#spectator_cam.translate(Vector3(0.0,0.2,1.0))

		
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

#	if GameVariables.battle_mode == GameVariables.BattleMode.CPU:
#		if last_battle_update + GameVariables.battle_interval < cue_emitter.current_playback_time :
#			last_battle_update = cue_emitter.current_playback_time
#			battle_module.evaluate_exercise()		

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
		
		#Remote messages can be consumed at a slower pace
		consume_remote_user_messages()



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
		
func add_statistics_element(ingame_id, state_string, cue_type, difficulty, points, hit, starttime, targettime, hr,max_hit_score, hardness):
	var statistics_element = {"e": state_string, "t": cue_type, "d": difficulty, "p": points, "h": hit, "st": starttime,"tt": targettime, "hr": hr,"mh":max_hit_score, "hd":hardness}
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
			if GameVariables.battle_mode != GameVariables.BattleMode.NO:
				battle_module.queue_cue(cue)
					
# Create the actual cue node add it to the scene and the statistics
func create_and_attach_cue_actual(cue_data):
	var cue_type = cue_data["cue_type"]
	var x = exercise_builder.eval_expression(cue_data["x"])
	var y = exercise_builder.eval_expression(cue_data["y"])
	var target_time = cue_data["target_time"]
	var fly_offset = cue_data["fly_offset"]
	var fly_time = cue_data["fly_time"]
	var cue_subtype = cue_data["cue_subtype"]
	var ingame_id = cue_data["ingame_id"]
	var hit_velocity = cue_data["hit_velocity"]
	var hit_score = cue_data["hit_score"]
	var fly_distance = cue_data.get("fly_distance", exercise_builder.fly_distance)
	var hardness = cue_data.get("hardness", 0)
	var curved_direction = cue_data.get("curved", 0)
	
	var is_head = false
	var is_avoid = false
	var cue_node
	if cue_type == "right" or cue_type == "right_hold":
		cue_node = cue_horiz.instance()
	elif cue_type == "left" or cue_type == "left_hold":
		cue_node = cue_vert.instance()
	elif cue_type == "head_avoid_block":
		is_head = true
		is_avoid = true
		cue_node = cue_squat_avoid.instance()
	elif cue_type == "head_avoid_bar":
		is_head = true
		is_avoid = true
		cue_node = cue_avoid_bar.instance()
	elif cue_type == "weight":
		is_head = false
		is_avoid = false
		cue_node = cue_weight.instance()
	else:
		head_y_pos = y
		if cue_type == "head_avoid":
			is_head = true
			is_avoid = true
			cue_node = cue_head_avoid.instance()
		else:
			is_head = true
			cue_node = cue_head.instance()
			cue_node.stars = hardness
			if cue_type == "head_extended":
				cue_node.extended = true
	if cue_type in ["right_hold", "left_hold"]:
		cue_node.is_hold_cue = true
		cue_node.hold_time = 0.25
		var  dd_dt = fly_distance/fly_time
		if dd_dt > 0:
			#Calculate the hold time based on the assumed arm length
			cue_node.hold_time = 0.35*GameVariables.player_height / dd_dt  
		print ("Hold time %.4f %.f"%[cue_node.hold_time, GameVariables.player_height])		
		
		
	cue_node.target_time = target_time
	cue_node.start_time = cue_emitter.current_playback_time
	#print ("Add cue node: now: %f  target_time: %f"%[cue_node.start_time, cue_node.target_time])
	var actual_flytime = fly_time
	if actual_flytime == 0:
		actual_flytime = exercise_builder.fly_time
	
	cue_node.hit_score = hit_score
	
	var main_node = get_node("cue_emitter")
	
	#If the player hits a streak of cues the next one will be special
	if cue_streak and not is_avoid:
		cue_streak = false
		var highlight = cue_highlight.instance()
		highlight.get_node("AnimationPlayer").play("rotation")
		if is_head:
			highlight.scale = highlight.scale * 6
		cue_node.add_child(highlight)
		cue_node.point_multiplier = 3.0
	main_node.add_child(cue_node)
	cue_node.translation = Vector3(x,y,0+fly_offset)
	
	if cue_type == "head_inverted":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3.1415926))
	elif cue_type == "head_left":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3.1415926/2))
	elif cue_type == "head_right":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3*3.1415926/2))
	
	if hit_velocity != null:
		cue_node.velocity_required = hit_velocity

	#Heartrate is stored with the start of the cue because that's the only definitive timestamp we know
	add_statistics_element(ingame_id, exercise_builder.state_string(actual_game_state)+"/%s"%cue_subtype, cue_type, exercise_builder.current_difficulty, 0, false, cue_emitter.current_playback_time, target_time, GameVariables.current_hr, hit_score, hardness)
	cue_node.ingame_id = ingame_id
	
	cue_emitter.set_move_tween(cue_node, Vector3(x,y,0+fly_offset),Vector3(x,y,fly_distance+fly_offset),actual_flytime, curved_direction)

	return cue_node

	

func get_start_exercise():
	var retVal = CueState.STAND
	
	if len(exercise_builder.state_list) > 0:
		retVal = exercise_builder.string_to_state(exercise_builder.get_current_state_from_list())
		exercise_builder.state_duration = exercise_builder.get_current_duration_from_list()
		actual_game_state = retVal
		actual_state_duration = exercise_builder.state_duration
		exercise_builder.min_state_duration = exercise_builder.state_duration
		#print ("Using preset workout  %s/%s"%[exercise_builder.cue_emitter_state,exercise_builder.state_duration])

	else:
		var states = { 	CueState.STAND  : ProjectSettings.get("game/exercise/stand"),
						CueState.SQUAT  : ProjectSettings.get("game/exercise/squat"),
						CueState.PUSHUP  : ProjectSettings.get("game/exercise/pushup"),
						CueState.CRUNCH  : ProjectSettings.get("game/exercise/crunch"),
						CueState.JUMP  : ProjectSettings.get("game/exercise/jump"),
						CueState.BURPEE  : ProjectSettings.get("game/exercise/burpees"),
						CueState.SPRINT  : ProjectSettings.get("game/exercise/sprint"),
						CueState.YOGA  : ProjectSettings.get("game/exercise/yoga"),
						CueState.PARCOUR  : ProjectSettings.get("game/exercise/parcour"),
						CueState.WEIGHTS  : ProjectSettings.get("game/exercise/weights"),
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
					CueState.PARCOUR  : ProjectSettings.get("game/exercise/parcour"),
					CueState.WEIGHTS  : ProjectSettings.get("game/exercise/weights"),
				}
				
	for key in states:
		exercise_builder.exercise_state_model[key] = {}
		for key_2 in states:
			if exercise_state_model_template[key].has(key_2):
				var val = exercise_state_model_template[key][key_2]
				if key != key_2 and states[key_2]:
					exercise_builder.exercise_state_model[key][key_2] = val
	#print (str(exercise_builder.exercise_state_model))
	
	exercise_builder.stand_state_model = exercise_builder.stand_state_model_template.duplicate(true)
	
	
class SprintObject:
	var hit_score = 1.0
	var ingame_id = -1
	func _init(ingame_id, hit_score):
		self.ingame_id = ingame_id
		self.hit_score = hit_score
		
var sprint_multiplier = 15.0
var last_sprint_update = 0
func handle_sprint_cues_actual(target_time):
	switch_floor_sign_actual("feet")
	var now = OS.get_ticks_msec()
	var delta = now - last_sprint_update
	var points = sprint_multiplier * running_speed * delta / 1000.0
	last_sprint_update = now
	var max_hit_score = 1.0
	var actual_hit_score = exercise_builder.eval_running_speed(running_speed)
	var ingame_id = add_statistics_element(GameVariables.get_next_ingame_id(), exercise_builder.state_string(exercise_builder.cue_emitter_state), "", exercise_builder.current_difficulty, points, actual_hit_score, cue_emitter.current_playback_time, cue_emitter.current_playback_time, GameVariables.current_hr, max_hit_score, 0)
	var obj = SprintObject.new(ingame_id, actual_hit_score)
	cue_emitter.score_points(actual_hit_score, points, obj)
	if GameVariables.battle_mode != GameVariables.BattleMode.NO:
		battle_module.hit_scored_opponent(null)

var actual_game_state  
var actual_state_duration = 0
var actual_last_state_change = 0
func internal_state_change():	
	if actual_game_state != CueState.SPRINT:
		get_tree().current_scene.set_controller_visible(true)
		
	if actual_game_state == CueState.SPRINT:
		last_sprint_update = OS.get_ticks_msec()
		
	if actual_game_state == CueState.BURPEE or actual_game_state == CueState.PUSHUP:
			update_safe_pushup()	
		
	emit_signal("set_exercise", actual_game_state)	

	GameVariables.player_exercise_state = actual_game_state
		
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
		$SafePushup.hide()
		var main_camera = GameVariables.vr_camera
		if actual_game_state == CueState.BURPEE or actual_game_state == CueState.PUSHUP:
			main_camera.show_hud(true)
			gu.activate_node(get_node("PushupView"))
			get_node("MainStage/mat").open_mat()
		else:
			get_node("MainStage/mat").close_mat()
			gu.deactivate_node(get_node("PushupView"))
			main_camera.show_hud(false)
	else:
		$SafePushup.print_info("Safe pushups not enabled!\ngo to settings to change")
		$SafePushup.show()
		
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
		boxman.switch_to_burpee()
	elif state == CueState.SPRINT:
		boxman.switch_to_run() 


func _on_exit_button_pressed():
	if stream:
		stream.stop()
	emit_signal("level_finished_manually")

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
		if actual_game_state == CueState.STAND:
			xx.show()
		else:
			xx.hide()
		xx.stop()
		run_point_multiplier = 1

	var now = OS.get_ticks_msec()
	var delta = (now-last_run_update)/1000.0
	if last_run_update > 0 and run_point_multiplier > 1:
		trophy_list.set_runtime(trophy_list.runtime + delta)
	
	cue_emitter.run_point_multiplier = run_point_multiplier
	
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


func end_level():
	stream.stop()
	
	if len(remote_user_scores) > 0:
		var winner = get_winner()
		var winner_panel = load("res://scenes/WinnerPanel.tscn").instance()
		winner_panel.set_winner ( winner == "Player")
		winner_panel.set_points(cue_emitter.points)
		add_child(winner_panel)
		winner_panel.translation = Vector3(0,1.34,-2.94)
		winner_panel.rotation = Vector3(PI/2,0,0)
	
	
	var t = Timer.new()	
	t.connect("timeout", self, "_on_exit_timer_timeout")
	t.set_wait_time(5)
	self.add_child(t)
	t.start()


func _on_AudioStreamPlayer_finished():
	end_level()
	
#Returns true if the current state supports claws
func beast_mode_supported():
	return exercise_builder.cue_emitter_state == CueState.STAND or boxman1.in_beast_mode or boxman2.in_beast_mode

func _on_boxman_beast_attack_successful():
	cue_emitter.score_negative_hits(10)

func _on_boxman_beast_killed():
	cue_emitter.score_positive_hits(10)

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
	
	#Make sure the controller is still available when accessing those attributes
	
	
	var node = cue_emitter.get_closest_cue(controller.global_transform.origin, "hand", controller.is_left)
	print ("Tracking lost. Closest object: %s"%str(node))
	if node:
		if node.global_transform.origin.distance_to(controller.global_transform.origin) < auto_hit_distance:
			var type = "right"
			if controller.is_left:
				type = "left"
			GameVariables.hit_player.play(0)
			node.has_been_hit(type)
	print ("Tracking compensation done")
		
func controller_tracking_regained(controller):
	var node = cue_emitter.get_closest_cue(controller.global_transform.origin, "hand", controller.is_left)
	print ("Tracking regained. Closest object: %s"%str(node))

	if node:
		
		if node.global_transform.origin.distance_to(controller.global_transform.origin) < auto_hit_distance:
			var type = "right"
			if controller.is_left:
				type = "left"
			GameVariables.hit_player.play(0)
			node.has_been_hit(type)
	print ("Tracking compensation done")

func play_encouragement():
	var selector = rng.randi()%6
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
	elif selector == 5:
		get_node("VoiceInstructor").say("very good")
	

var knee_high_ok = true
func _on_cue_emitter_streak_changed(count):
	if gu.hardness_level() >= 2:
		knee_high_ok = true
	if count > 0 and count % 15 == 0:
		cue_streak = true
	if count == 15:
		if actual_game_state == CueState.SPRINT:
			if run_point_multiplier >= 3:
				var e = gu.get_current_energy()
				if knee_high_ok and e < (0.6*GameVariables.energy_level_medium + 0.4*GameVariables.energy_level_high):
					#Player is running fast enough but not using a high knee running
					$VoiceInstructor.say("i want to see those knees higher")
					knee_high_ok = false
				else:
					play_encouragement()
			else:
				get_node("VoiceInstructor").say("faster")
		else:					
			play_encouragement()

func _on_BattleDisplay_player_won(player):
	end_level()


func _on_SkipExerciseButton_touched():
	print ("Force state change")
	exercise_builder.force_state_change()

enum TournamentState {
	PLAYER_AHEAD = 1,
	PLAYER_BEHIND = 2
	}
	
class PointSorter:	
	static func point_compare(a, b):
		return a[1] > b[1]
	
var player_tournament_state = 0
var remote_user_scores = Dictionary()
var remote_user_messages = Dictionary()
var remote_user_names = Dictionary()
func consume_remote_user_messages():
	var tmp_score = Array()
	tmp_score.append([-1, cue_emitter.points])
	
	for k in remote_user_messages:
		var username = remote_user_names[k]
		while len(remote_user_messages[k]) > 0 and remote_user_messages[k][0]["tt"] < cue_emitter.current_playback_time:
			var el = remote_user_messages[k].pop_front()
			var hit = el["h"]
			if typeof(hit) == TYPE_BOOL:
				if hit:
					hit = float(el.get("mh",1.0))
				else:
					hit = 0.0
			
			if not remote_user_scores.has(k):
				remote_user_scores[k] = {"name": username, "score": 0.0, "points": 0.0}

			remote_user_scores[k]["score"] = remote_user_scores[k].get("score",0.0) + hit
			remote_user_scores[k]["points"] = remote_user_scores[k].get("points",0.0) + float(el["p"])
			#print ("Remote score (%s): %s/%f"%[username, str(el["p"]), hit])

		if remote_user_scores.has(k):
			tmp_score.append([k, remote_user_scores[k]["points"]])
		else:
			tmp_score.append([k, 0])
	
	
	tmp_score.sort_custom(PointSorter, "point_compare")
	print ("Sorted ranks: %s"%str(tmp_score))
	var player_rank_index = Dictionary()
	for sc_idx in len(tmp_score):
		player_rank_index[tmp_score[sc_idx][0]] = sc_idx


	for k in remote_user_scores:
		var username = remote_user_names[k]
		var rank = player_rank_index[k]
		emit_signal("update_user_points", k, remote_user_scores[k].get("points", 0.0), rank+1)
		$TrophyList.set_score(username, remote_user_scores[k].get("name", "Unknown Player"),remote_user_scores[k].get("score",0.0), remote_user_scores[k].get("points", 0.0) )
	
	
	if len(remote_user_scores) > 0:
		var points = 0
		for k in remote_user_scores:
			if remote_user_scores[k].get("points",0) > points:
				points = remote_user_scores[k].get("points",0)
		if player_tournament_state != TournamentState.PLAYER_AHEAD and cue_emitter.points > points + 1000:
			get_node("VoiceInstructor").say("pulled_ahead")
			player_tournament_state = TournamentState.PLAYER_AHEAD
		elif player_tournament_state != TournamentState.PLAYER_BEHIND and cue_emitter.points < points - 1000:
			get_node("VoiceInstructor").say("falling_behind")
			player_tournament_state = TournamentState.PLAYER_BEHIND
	
func get_winner():
	var winner = "Player"
	var winning_points = cue_emitter.points
	if len(remote_user_scores) > 0:
		for k in remote_user_scores:
			if remote_user_scores[k].get("points", 0.0) > winning_points:
				winner = remote_user_scores[k].get("name", "Unknown Player")
				winning_points = remote_user_scores[k].get("points", 0.0)
	return winner
	
func _on_cue_hit_scored(hit_score, base_score, points, obj):
	if obj and "ingame_id" in obj:
		var ingame_id = obj.ingame_id
		var statistics_element = GameVariables.level_statistics_data [ingame_id]
		send_statistics_elements({ingame_id : statistics_element})

func send_statistics_elements(elements):
	if GameVariables.multiplayer_api and GameVariables.multiplayer_api.is_multiplayer():
		GameVariables.multiplayer_api.send_game_message({"type":"remote_statistics_data","statistics":elements})
	
func add_remote_user_messages(user, messages, user_id):
	remote_user_names[user_id] = user
	if not remote_user_messages.has(user_id):
		remote_user_messages[user_id] = Array()
	var klist = messages.keys()
	klist.sort()
	
	for m in klist:
		remote_user_messages[user_id].append(messages[m])
		
	
	
