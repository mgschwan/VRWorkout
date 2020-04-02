extends Spatial


signal level_finished

var song_index_parameter = 0
export var random_seed = true

var beats = []
var bpm = 60 #only used in freeplay mode
var first_beat = 0 #only used in freeplay mode
var beat_index = 0
var selected_song = 0
var stream
var fly_time = 3.0
var emit_early = 0 #Time it takes the cue to reach the target area. autocalculated
var fly_distance = 0.0 #How far the cue flies, autocalculated
var player_height = 0
var run_point_multiplier = 1
var beast_mode
	
var running_speed = 0
	
var current_difficulty = 0

var cue_horiz = preload("res://cue_h_obj.tscn")
var cue_vert = preload("res://cue_v_obj.tscn")
var cue_head = preload("res://cue_head_obj.tscn")
var environment = preload("res://outdoor_env.tres")
var infolayer

var cue_emitter
var target
var boxman1
var boxman2





enum CueState {
	STAND = 0,
	SQUAT = 1,
	PUSHUP = 2,
	CRUNCH = 3,
	JUMP = 4,
};

enum CueSelector {
	HEAD = 0,
	HAND = 1,	
};
	
	
var cue_paramerters = {
	CueState.STAND : {
		CueSelector.HEAD : {
		},
		CueSelector.HAND : {
		}
	},	
	CueState.SQUAT : {
		CueSelector.HEAD : {
			"yoffset" : 0.0,
			"yrange" : 0.5,
		},
		CueSelector.HAND :  {
			"xspread" : 0.6
		}		
	},	
	CueState.PUSHUP : {
		CueSelector.HEAD : {
			"xrange" : 0.4,
			"yoffset" : 0.2,
			"yrange" : 0.6
		},
		CueSelector.HAND : {
		}
	},	
	CueState.CRUNCH : {
		CueSelector.HEAD : {
			"xrange" : 0.3,
			"yoffset": 0.25,
			"yrange": 0.2
		},
		CueSelector.HAND : {
			"xrange" : 0.1
		}
	},	
	CueState.JUMP : {
		CueSelector.HEAD : {
		},
		CueSelector.HAND : {
		}
	}	
}


var cue_emitter_state = CueState.STAND
var cue_selector = CueSelector.HEAD

var level_min_cue_space = 1.0
var level_min_state_duration = 10.0

var min_cue_space = 1.0 #Hard: 1.0 Medium: 2.0 Easy: 3.0
var min_state_duration = 10.0 #Hard 5 Medium 15 Easy 30
var beast_chance = 0.1
var last_emit = 0.0
var state_transition_pause = 1.5
var head_y_pos = 0
var state_changed = true
var last_state_change = 0.0

var rng = RandomNumberGenerator.new()



func state_string(state):
	if state == CueState.STAND:
		return "stand"
	elif state == CueState.JUMP:
		return "jump"
	elif state == CueState.SQUAT:
		return "squat"
	elif state == CueState.PUSHUP:
		return "pushup"
	elif state == CueState.CRUNCH:
		return "crunch"
	
	return "unknown"

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
	
var update_counter = 0
func update_info(hits, max_hits, points):
	var song_pos = int(cue_emitter.current_playback_time)
	var total = int(stream.stream.get_length())
	infolayer.print_info("Hits %d/%d - Song: %d/%.1f%% - Points: %d - Speed: %.1f"% [hits,max_hits,song_pos,float(100*song_pos)/total,points,running_speed])
	if update_counter % 5 == 0:
		infolayer.print_info("Player height: %.2f Difficulty: %d/%.2f/%.2f"%[player_height, current_difficulty, min_cue_space, min_state_duration], "debug")
	update_counter += 1
	
func _ready():
	if random_seed:
		rng.randomize()
	else:
		rng.set_seed(0)
	infolayer = get_node("Viewport/InfoLayer")
	cue_emitter = get_node("cue_emitter")
	target = get_node("target")
	
	boxman1 = get_node("boxman")
	boxman2 = get_node("boxman2")
	
	update_cue_timing()
	
	var songs = File.new()
	songs.open('res://audio/songs.json', File.READ)
	
	var tmp = songs.get_as_text()
	var song_dict = JSON.parse(tmp).result
	songs.close()
	
	beat_index = 0

	setup_difficulty(current_difficulty)
	
	if song_index_parameter < 0:
		#freeplay mode
		stream = DummyAudioStream.new(abs(song_index_parameter)*100)
		selected_song = "Freeplay"
		print ("BPM %.2f"%bpm)
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
		stream.connect("stream_finished", self, "_on_AudioStreamPlayer_finished")
		self.add_child(stream)
	
	else:
		selected_song = song_dict.keys()[song_index_parameter]
	
		beats = song_dict[selected_song]

		var audio_file = File.new()
		var audio_filename = "res://audio/%s"%selected_song
		
		infolayer.print_info("Loading song %s"%audio_filename)
		audio_file.open(audio_filename,File.READ)
		infolayer.append_info(" / File opened %s" % str(audio_file.is_open()))
		infolayer.print_info(state_string(cue_emitter_state).to_upper(), "main")
		infolayer.print_info("Player height: %.2f Difficulty: %.2f/%.2f"%[player_height, min_cue_space, min_state_duration], "debug")

		var audio_resource = ResourceLoader.load(audio_filename)
		stream = get_node("AudioStreamPlayer")
		stream.stream = audio_resource
	stream.play()
	
func setup_difficulty(d):
	if d == 2:
		level_min_cue_space = 0.5
		level_min_state_duration = 10.0 
		beast_chance = 0.4
	elif d == 1:
		level_min_cue_space = 1.0
		level_min_state_duration = 15.0 
		beast_chance = 0.2
	else:	
		level_min_cue_space = 1.5
		level_min_state_duration = 20.0
		beast_chance = 0.1
	min_cue_space = level_min_cue_space
	min_state_duration = level_min_state_duration
	current_difficulty = d
		
var last_playback_time = 0
func _process(delta):
	#cue_emitter.current_playback_time += delta
	cue_emitter.current_playback_time = stream.get_playback_position()
	if beat_index < len(beats)-1 and cue_emitter.current_playback_time + emit_early > beats[beat_index]:	
		if last_emit + min_cue_space < cue_emitter.current_playback_time and last_state_change + state_transition_pause < cue_emitter.current_playback_time:
			emit_cue_node(beats[beat_index])
			last_emit = cue_emitter.current_playback_time
		beat_index += 1
	elif beat_index == len(beats)-1:
		beat_index += 1
		infolayer.print_info("FINISHED", "main")
	
	if cue_emitter.current_playback_time < last_playback_time:
		stream.stop()
	else:		
		last_playback_time = cue_emitter.current_playback_time
	
func _on_exit_timer_timeout():
	print ("End of level going back to main")
	emit_signal("level_finished")
	

func _on_tween_completed(obj,path):
	cue_emitter.score_miss()
	obj.queue_free()


func update_cue_timing():
	fly_distance = abs(cue_emitter.translation.z-target.translation.z) + 2	
	var time_to_target = abs(cue_emitter.translation.z-target.translation.z) / fly_distance
	emit_early = fly_time * time_to_target


func create_and_attach_cue(cue_type, x, y, target_time, fly_offset=0):
	cue_emitter.max_hits += 1
	var cue_node

	if cue_type == "right":
		cue_node = cue_horiz.instance()
	elif cue_type == "left":
		cue_node = cue_vert.instance()
	else:
		head_y_pos = y
		cue_node = cue_head.instance()

	cue_node.target_time = target_time
	cue_node.start_time = cue_emitter.current_playback_time
	
	var main_node = get_node("cue_emitter")
	var move_modifier = Tween.new()
	move_modifier.set_name("tween")
	cue_node.add_child(move_modifier)
	main_node.add_child(cue_node)
	cue_node.translation = Vector3(x,y,0+fly_offset)
	if cue_type == "head_inverted":
		cue_node.set_transform( cue_node.get_transform().rotated(Vector3(0,0,1), 3.1415926))
	
	if cue_type == "left" or cue_type == "right":
		var alpha = atan2(x,y-head_y_pos)
		cue_node.set_transform(cue_node.get_transform().rotated(Vector3(0,0,1),-alpha))
	
	move_modifier.interpolate_property(cue_node,"translation",Vector3(x,y,0+fly_offset),Vector3(x,y,fly_distance+fly_offset),fly_time,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	move_modifier.connect("tween_completed",self,"_on_tween_completed")
	move_modifier.start()
	return cue_node
	
var state_model = { CueState.STAND: { CueState.SQUAT: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10, CueState.JUMP: 10},
					CueState.SQUAT: { CueState.STAND: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10},
					CueState.PUSHUP: { CueState.STAND: 10, CueState.SQUAT: 10},
					CueState.CRUNCH: { CueState.STAND: 10, CueState.SQUAT: 10},
					CueState.JUMP: {CueState.STAND: 50}, 
					}
	
func state_transition(old_state):
	var state_selector = rng.randi()%100
	var new_state = old_state
	var probabilities = state_model[old_state]
	var cumulative_probability = 0
	for k in probabilities.keys():
		cumulative_probability += probabilities[k]
		if state_selector < cumulative_probability:
			new_state = k
			break
	return new_state
	
	
func handle_stand_cues():
	pass
	
func handle_jump_cues():
	pass
	
func handle_squat_cues():
	pass
	
func handle_crunch_cues():
	pass
	
func handle_pushup_cues():
	pass	
	
	
	

func emit_cue_node(target_time):
	print ("State: %s"%state_string(cue_emitter_state))
	
	var node_selector = rng.randi()%100
	
	var x = rng.randf() * 1.0 -0.5
	var y_hand = 1.0
	var y_head = 1.0
	var x_head = 0
	if cue_emitter_state == CueState.STAND:
		y_hand = player_height-0.2 + rng.randf() * 0.3
		y_head = player_height
		x = 0.2 + rng.randf() * 0.45
		x_head = rng.randf() - 0.5
	elif cue_emitter_state == CueState.JUMP:
		y_hand = player_height
		y_head = player_height + 0.32
		x = 0
		x_head = 0
	elif cue_emitter_state == CueState.SQUAT:
		y_head = player_height/2 + cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yrange"]
		y_hand = y_head + (rng.randf() * 0.4 - 0.2)
		x = 0.3 + rng.randf() * 0.45
		x_head = rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HAND]["xspread"] - cue_paramerters[cue_emitter_state][CueSelector.HAND]["xspread"]/2
	elif cue_emitter_state == CueState.CRUNCH:
		x_head = rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HEAD]["xrange"] - cue_paramerters[cue_emitter_state][CueSelector.HEAD]["xrange"]/2
		y_head = cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yrange"]
		y_hand = 0.8 + rng.randf() * 0.4
		x = rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HAND]["xrange"] - cue_paramerters[cue_emitter_state][CueSelector.HAND]["xrange"]/2
	else: #CueState.PUSHUP
		y_head = cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HEAD]["yrange"]
		x = 0.3 + rng.randf() * 0.25
		x_head = rng.randf() * cue_paramerters[cue_emitter_state][CueSelector.HEAD]["xrange"] - cue_paramerters[cue_emitter_state][CueSelector.HEAD]["xrange"]/2
		y_hand = 0.3 + rng.randf() * 0.4

	var double_punch = cue_emitter_state == CueState.STAND && rng.randf() < 0.5
	var double_punch_delay = 0.25
	var dd_df = fly_distance/fly_time


	if not state_changed and cue_selector == CueSelector.HAND and cue_emitter_state == CueState.CRUNCH:
		var spread = 0.2+rng.randf()*0.3
		create_and_attach_cue("right", x+spread,y_hand, target_time)
		create_and_attach_cue("left", x-spread,y_hand, target_time)
	elif cue_emitter_state == CueState.JUMP:
		cue_selector = CueSelector.HEAD
		create_and_attach_cue("head", x_head, y_head, target_time)
	elif not state_changed and cue_selector == CueSelector.HAND and node_selector < 50:
		var n = create_and_attach_cue("right", x,y_hand, target_time)
		if double_punch:
			var n2 = create_and_attach_cue("right", x*rng.randf(),(y_hand+player_height*(0.5+rng.randf()*0.2))/2, target_time + double_punch_delay, -double_punch_delay*dd_df)
			n.activate_path_cue(n2)
	elif not state_changed and cue_selector == CueSelector.HAND and node_selector >= 50:
		var n = create_and_attach_cue("left", -x,y_hand, target_time)
		if double_punch:
			var n2 = create_and_attach_cue("left", -x*rng.randf(),(y_hand+player_height*(0.5+rng.randf()*0.2))/2, target_time + double_punch_delay, -double_punch_delay*dd_df)
			n.activate_path_cue(n2)
	else:
		state_changed = false
		if cue_emitter_state == CueState.PUSHUP:
			create_and_attach_cue("head_inverted", x_head, y_head, target_time)
		else:
			create_and_attach_cue("head", x_head, y_head, target_time)

	if cue_selector == CueSelector.HAND:
		if cue_emitter_state == CueState.STAND:
			if node_selector < 10:
				cue_selector = CueSelector.HEAD
		elif cue_emitter_state == CueState.CRUNCH:
			if node_selector < 80:
				cue_selector = CueSelector.HEAD
		elif node_selector < 30:
			cue_selector = CueSelector.HEAD
	elif cue_selector == CueSelector.HEAD:
		if cue_emitter_state == CueState.STAND:
			if node_selector < 50:
				cue_selector = CueSelector.HAND
		elif cue_emitter_state == CueState.CRUNCH:
			if node_selector < 80:
				cue_selector = CueSelector.HAND
		elif node_selector < 25:
			cue_selector = CueSelector.HAND
			
	# Increase the cue speed for hand cues
	if cue_selector == CueSelector.HAND:
		min_cue_space = level_min_cue_space / 2
	else:
		min_cue_space = level_min_cue_space
			
	if last_state_change + min_state_duration < cue_emitter.current_playback_time:
		var old_state = cue_emitter_state
		cue_emitter_state = state_transition(cue_emitter_state)
		if old_state != cue_emitter_state:
			#Emit a head cue if the state has changed
			state_changed = true
			last_state_change = cue_emitter.current_playback_time
			infolayer.print_info(state_string(cue_emitter_state).to_upper(), "main")
			get_node("PositionSign").start_sign(cue_emitter.translation, get_node("target").translation, emit_early)
			if not boxman1.in_beast_mode:
				switch_boxman(cue_emitter_state,"boxman")
			if not boxman2.in_beast_mode:
				switch_boxman(cue_emitter_state,"boxman2")
			display_state(cue_emitter_state)
	if cue_emitter_state == CueState.STAND and beast_mode:
		if not boxman1.in_beast_mode and not boxman2.in_beast_mode:
			if rng.randf() < beast_chance:
				var boxman = boxman1 
				if rng.randf() < 0.5:
					 boxman = boxman2
				boxman.activate_beast(Vector3(0,0,1),1.8)

func switch_boxman(state, name):
	var boxman = get_node(name)
	if cue_emitter_state == CueState.STAND:
		boxman.switch_to_stand()
	elif cue_emitter_state == CueState.JUMP:
		boxman.switch_to_jumping()
	elif cue_emitter_state == CueState.SQUAT:
		boxman.switch_to_squat()
	elif cue_emitter_state == CueState.CRUNCH:
		boxman.switch_to_situps()
	elif cue_emitter_state == CueState.PUSHUP:
		boxman.switch_to_plank()


func _on_exit_button_pressed(body):
	emit_signal("level_finished")

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

func get_points():
	return {"points": cue_emitter.points, "hits": cue_emitter.hits, "max_hits": cue_emitter.max_hits,"time": last_playback_time}
		
var gui_update = 0	
func _on_UpdateTimer_timeout():
	running_speed = self.get_parent().get_running_speed()
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
	return cue_emitter_state == CueState.STAND or boxman1.in_beast_mode or boxman2.in_beast_mode

func _on_boxman_beast_attack_successful():
	cue_emitter.score_negative_hits(10)


func _on_boxman_beast_killed():
	cue_emitter.score_positive_hits(10)
