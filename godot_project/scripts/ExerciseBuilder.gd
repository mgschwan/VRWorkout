extends Node

var CueState = GameVariables.CueState
var CueSelector = GameVariables.CueSelector
var SquatState = GameVariables.SquatState
var StandState = GameVariables.StandState
var CrunchState = GameVariables.CrunchState



var PushupState = GameVariables.PushupState

var stand_state_model_template
var squat_state_model_template

var cue_emitter_state = -1
var last_state_change = 0.0

var cue_emitter_list = []
var cue_parameters = {}
var player_height = 0
var fly_time = 3.0
var fly_distance = 0
var target_distance = 0
var hand_delay = 0
var jump_offset = 0.42
var ducking_mode = false
var stand_avoid_head_cue = 0.5
var kneesaver_mode = false
var beast_chance = 0.1
var emit_early
var auto_difficulty = false



var rng = RandomNumberGenerator.new()

var cue_selector = CueSelector.HEAD

var temporary_cue_space_extension = 0.0
var state_transition_pause = 1.5
var adjust_state_transition_pause = ProjectSettings.get("game/easy_transition")

var rebalance_exercises = true
var redistribution_speed = 0.025

var hand_cue_offset = 0.60

var exercise_changed = true


var min_cue_space = 1.0 #Hard: 1.0 Medium: 2.0 Easy: 3.0
var min_state_duration = 10.0 #Hard 5 Medium 15 Easy 30

var level_min_state_duration = 10.0
var level_min_cue_space = 1.0

var state_list = []
var state_list_index = 0
var state_duration = 0
var exercise_state_model = {}
var current_difficulty = 0

var last_emit = 0



func _ready():
	pass




func reset_cue_spacing():
	min_cue_space = level_min_cue_space

func adjust_cue_spacing():
	# Increase the cue speed for hand cues
	if cue_selector == CueSelector.HAND:
		min_cue_space = level_min_cue_space / 2
	else:
		min_cue_space = level_min_cue_space

func insert_cue_sorted(ts, cue_data):
	var selected_idx = 0
	for cidx in range(len(cue_emitter_list)):
		if ts < cue_emitter_list[cidx][0]:
			break
		selected_idx = cidx + 1
	cue_emitter_list.insert(selected_idx, [ts, cue_data])

func create_and_attach_cue(ts, cue_type, x, y, target_time, fly_offset=0, fly_time = 0, cue_subtype="", target_cue = null, hit_velocity = null, hit_score = 1.0):
	#Cue IDs have to be generated when they are added to the list so others can reference it
	var ingame_id = GameVariables.get_next_ingame_id()
	var cue_data = {
		"cue_type": cue_type, 
		"x": x, 
		"y": y,
		"target_time": target_time, 
		"fly_offset": fly_offset, 
		"fly_time": fly_time, 
		"cue_subtype": cue_subtype, 
		"ingame_id": ingame_id,
		"target_cue": target_cue,
		"hit_velocity": hit_velocity,
		"hit_score": hit_score,
		"fly_distance": fly_distance
		}
	#print (str(cue_data))
	insert_cue_sorted(ts, cue_data)
	return ingame_id  #true #create_and_attach_cue_actual(cue_type, x, y, target_time, fly_offset, fly_time , cue_subtype)


func switch_floor_sign(ts, floorsign):
	var cue_data = 	{
		"cue_type": "floor_sign", 
		"state": floorsign, 
		"target_time": ts, 
		}
	insert_cue_sorted(ts, cue_data)

#Returns a copy of the model without the state as a target
func model_without_state(model, state):
	var new_model = {}
	for s in model:
		var tmp = model[s].duplicate(true)
		tmp.erase(state)
		new_model[s] = tmp
	return new_model

func update_distribution(distribution, index, delta):
	var tmp = delta / len(distribution)
	var total = 0
	for k in distribution.keys():
		if k != index:
			distribution[k] = min(0.99, distribution[k] + tmp)
			total = total + distribution[k]
	distribution[index] = max (0.01, distribution[index]-delta)
	total = total + distribution[index]
	for k in distribution.keys():
		distribution[k] = distribution[k] / total
	return distribution
	

# If current_distribution is set the probabilities are normalized by the actual distribution
func state_transition(old_state, state_model, current_distribution = null, allow_self_transition = true):
	var probabilities = state_model[old_state].duplicate(true)
	print ("Old state: %d(%s)"%[old_state, state_string(old_state)])
	print ("Probabilities pre: %s (%d)"%[str(probabilities),old_state])
	if len(probabilities) < len(state_model):
		var sum = 0
		for k in probabilities.keys():
			sum = sum + probabilities[k]
		probabilities[old_state] = max(0,100-sum)

	#If the actual state must not be the target state remove it
	if not allow_self_transition:
		print ("Remove old state %d"%old_state)
		if probabilities.has(old_state):
			print ("Remove")
			probabilities.erase(old_state)
			print ("Probabilities mid: %s"%str(probabilities))
			
	if current_distribution != null:
		if len(current_distribution) < len(state_model):
			current_distribution.clear()
			for k in state_model.keys():
				current_distribution[k] = 1.0/len(state_model)
		var total = 0
		for k in probabilities.keys():
			probabilities[k] = probabilities[k] * current_distribution[k]
			total = total + probabilities[k]
		for k in probabilities.keys():
			probabilities[k] = 100 * probabilities[k] / total
		print ("Probabilities: %s"%str(probabilities))
	var state_selector = rng.randi()%100
	var new_state = old_state
	var sum = 0
	print ("Probabilities actual: %s"%str(probabilities))
	for p in probabilities:
		sum += probabilities[p]
	print ("Probabilit sum: %f"%sum)
	
	#If the probabilities don't add up to 1 rescale them
	var factor = 1.0
	if sum > 0 and sum < 100:
		factor = 100.0/sum	
	print ("Factor: %f"%factor)
	print ("State selector: %d"%state_selector)
	if len(probabilities) > 0:
		var cumulative_probability = 0
		new_state = probabilities.keys()[0]
		var keys = probabilities.keys()
		print (str(keys))
		keys.sort()
		for k in keys:
			cumulative_probability += factor * probabilities[k]
			if state_selector < cumulative_probability:
				new_state = k
				break
	
	if current_distribution != null:
		current_distribution = update_distribution(current_distribution, new_state, redistribution_speed)
		print ("Distribution: %s"%str(current_distribution))
	return new_state

func set_fly_distance(fly_distance, target_distance):
	self.fly_distance = fly_distance
	self.target_distance = target_distance
	print ("Fly distance: %s / %s"%[str(self.fly_distance), str(self.target_distance)])
	
func update_cue_timing():
	var time_to_target = target_distance / fly_distance
	emit_early = fly_time * time_to_target
	
func setup_difficulty(diff, auto_difficulty = false, avg_hr=0, target_hr=0):
	self.auto_difficulty = auto_difficulty
	if auto_difficulty:
		diff = 1.0 + min(1.0,max(-1.0,(target_hr - avg_hr+5.0)/20.0))
	else:
		#Keep the difficulty in the supported bounds	
		diff = min(2,max(0,diff))
	
	var d = diff
	
	if len(state_list) > 0:
		level_min_state_duration = get_current_duration_from_list()
	else:		
		level_min_state_duration = 20 - d * 2.5 
	
	beast_chance = 0.1 + d/10.0
	level_min_cue_space = 1.5 - d*0.6
	fly_time = 3.5-(d/2	)
	
			
	min_cue_space = level_min_cue_space
	min_state_duration = level_min_state_duration
	state_duration = min_state_duration
	current_difficulty = d

	update_cue_timing()

	setup_cue_parameters(d, player_height)

#Populate the cue parameters according to difficulty and player height
func setup_cue_parameters(difficulty, ph):
	player_height = ph
	
	cue_parameters = {
		CueState.STAND : {
			CueSelector.HEAD : {
				"xrange" : 1.0,
				"yoffset" : 0.0
			},
			CueSelector.HAND : {
				"xoffset" : 0.2,
				"xrange" : 0.45,
				"yoffset" : -0.2 - difficulty * 0.1,
				"yrange" : 0.3 + difficulty * player_height/8.0,
				"double_swing_spread": player_height/ ( 3.0 + (2.0-difficulty)/1.5 ) 
			}
		},	
		CueState.SQUAT : {
			CueSelector.HEAD : {
				"yoffset" : 0.0,
				"yrange" : player_height * 0.3,
			},
			CueSelector.HAND :  {
				"xspread" : 0.6,
				"yrange" : 0.4,
				"double_swing_spread": player_height/ ( 3.0 + (2.0-difficulty)/1.5 ) 
			}		
		},	
		CueState.PUSHUP : {
			"sideplank_cue_space": 2.5 - difficulty/2.0,
			"sideplank_has_pushup": difficulty > 0.9,
			CueSelector.HEAD : {
				"xrange" : 0.4,
				"yoffset" : 0.25,
				"yrange" : 0.55
			},
			CueSelector.HAND : {
			}
		},	
		CueState.CRUNCH : {
			CueSelector.HEAD : {
				"xrange" : 0.3,
				"yoffset": 0.35,
				"yrange": 0.1
			},
			CueSelector.HAND : {
				"rotation_range": difficulty*35, #increase core rotation with difficulty
				"xrange" : 0.1,
				"xspread" : max(0.1, 0.2 - difficulty/10.0), #If core rotation increases, decrease spread
				"yoffset" : player_height * 0.526 + difficulty * player_height/20.0,
				"yrange" : 0.2
			}
		},	
		CueState.JUMP : {
			CueSelector.HEAD : {
				"yoffset" : jump_offset,
			},
			CueSelector.HAND : {
				"has_hand" : difficulty > 0.9,
				"yoffset" : jump_offset,
				"xspread" : player_height / 5.0,
			}
		},
		CueState.BURPEE : {
			"burpee_length": 4.5 - difficulty/2.0,
			CueSelector.HEAD : {
				"yoffset" : 0.6
			},
			CueSelector.HAND : {
				"has_hand" : difficulty > 0.9,
				"yoffset" : jump_offset,
				"xspread" : player_height / 5.0,
			}
		},	
		CueState.YOGA : {
			CueSelector.HEAD : {
			},
			CueSelector.HAND : {
			}
		}	
	}
	if kneesaver_mode:
		cue_parameters[CueState.SQUAT][CueSelector.HEAD]["yoffset"] = player_height * 0.18
	
	#Easy difficulties don't have double swings
	if difficulty < 1.0:
		stand_state_model = model_without_state(stand_state_model_template, StandState.DOUBLE_SWING)
		squat_state_model = model_without_state(squat_state_model_template, SquatState.DOUBLE_SWING)
	else:
		stand_state_model = stand_state_model_template.duplicate(true)
		squat_state_model = squat_state_model_template.duplicate(true)
	stand_state = StandState.REGULAR
	

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
	elif state == CueState.BURPEE:
		return "burpee"
	elif state == CueState.SPRINT:
		return "sprint"
	elif state == CueState.YOGA:
		return "yoga"
	
	return "unknown"

func string_to_state(s):
	var  retVal = CueState.STAND
	if s == "stand":
		retVal = CueState.STAND
	elif s == "jump":
		retVal = CueState.JUMP
	elif s == "squat":
		retVal = CueState.SQUAT
	elif s == "pushup":
		retVal = CueState.PUSHUP
	elif s == "crunch":
		retVal = CueState.CRUNCH
	elif s == "burpee":
		retVal = CueState.BURPEE
	elif s == "sprint":
		retVal = CueState.SPRINT
	elif s == "yoga":
		retVal = CueState.YOGA
	return retVal


func next_state_from_list():
	state_list_index = (state_list_index + 1) % len(state_list)
	cue_emitter_state = string_to_state(get_current_state_from_list())
	state_duration = get_current_duration_from_list()
	level_min_state_duration = state_duration
	min_state_duration = state_duration
	print ("State duration %.2f"%float(state_duration)) 
	
func get_current_state_from_list():
	var retVal = "stand"
	if len(state_list) > 0 and state_list_index < len(state_list):
		retVal = state_list[state_list_index][0]
	return retVal

func get_current_duration_from_list():
	var retVal = 1.0
	if len(state_list) > 0 and state_list_index < len(state_list):
		retVal = state_list[state_list_index][1]
	return retVal	

func builder_state_changed(current_time):
	last_state_change = current_time

func get_weights(diff):
	var w_low
	var w_high
	var delta = diff
	if diff < 1.0:
		w_low = GameVariables.difficulty_weight_adjustments["easy"]
		w_high = GameVariables.difficulty_weight_adjustments["medium"]
	else:
		w_low = GameVariables.difficulty_weight_adjustments["medium"]
		w_high = GameVariables.difficulty_weight_adjustments["hard"]
		delta = diff-1.0
		
	var combined_weights = {}
	for k in w_low:
		combined_weights[k] = (1.0-delta)*w_low[k] + delta*w_high[k]				

	return combined_weights
	
func adjust_state_model(diff, model):
	var weights = get_weights(diff)
	print ("Weights: %s"%str(weights))
	var retVal = model.duplicate(true)
	for k in retVal:
		var sum = 0
		var total = 0
		for k2 in retVal[k]:
			sum += retVal[k][k2]*weights[k2]
			total += retVal[k][k2] 
		if sum > 0:
			for k2 in retVal[k]:
				retVal[k][k2] = total*( retVal[k][k2]*weights[k2] )/sum

	return retVal

var emitter_state_changed = false
func emit_cue_node(current_time, target_time):
	if last_state_change + state_duration < current_time or cue_emitter_state < 0:
		var old_state = cue_emitter_state
		if len(state_list) > 0:
			print ("Take preset state")
			next_state_from_list()
		else:
			print ("Take random state\n\n\n\n")		
			if auto_difficulty:
				print ("Model prejadjust: %s"%str(exercise_state_model))
				var adjusted_model = adjust_state_model(current_difficulty, exercise_state_model)
				print ("Model postadjust: %s"%str(adjusted_model))
				
				cue_emitter_state = state_transition(cue_emitter_state, adjusted_model, null, false)
				print ("New state (%d) %s\n\n\n\n"%[cue_emitter_state, state_string(cue_emitter_state)])
			else:
				print ("Take from standard model %s"%str(auto_difficulty))
				cue_emitter_state = state_transition(cue_emitter_state, exercise_state_model, null, false)
			state_duration = min_state_duration + 5*current_difficulty*rng.randf()
		state_transition_pause = get_state_transition_pause(old_state, cue_emitter_state)
		print ("State transition pause %.2f"%state_transition_pause)
		var cue_data = {
		"cue_type": "state_change",
		"state": cue_emitter_state, 
		"target_time": target_time, 
		"state_duration": state_duration
		}
		
		
		
		insert_cue_sorted(current_time, cue_data)
		emitter_state_changed = true
		builder_state_changed(current_time)
	
	
	reset_cue_spacing()
	if not emitter_state_changed:
		if cue_emitter_state == CueState.STAND:
			adjust_cue_spacing()
			handle_stand_cues(current_time, target_time, cue_emitter_state)
		elif cue_emitter_state == CueState.JUMP:
			handle_jump_cues(current_time, target_time, cue_emitter_state)
		elif cue_emitter_state == CueState.SQUAT:
			adjust_cue_spacing()
			handle_squat_cues(current_time, target_time, cue_emitter_state)
		elif cue_emitter_state == CueState.CRUNCH:
			adjust_cue_spacing()
			handle_crunch_cues(current_time, target_time, cue_emitter_state)
		elif cue_emitter_state == CueState.BURPEE:
			handle_burpee_cues(current_time, target_time, cue_emitter_state)
		elif cue_emitter_state == CueState.SPRINT:
			pass #handle_sprint_cues(target_time)
		elif cue_emitter_state == CueState.YOGA:
			handle_yoga_cues(current_time, target_time, cue_emitter_state)
		else: #CueState.PUSHUP
			handle_pushup_cues(current_time, target_time, cue_emitter_state)
		exercise_changed = false
	else:			
		exercise_changed = true
		emitter_state_changed = false






############################# JUMP ######################################

func handle_jump_cues(current_time, target_time, cue_emitter_state):
	switch_floor_sign(current_time,"feet")
	var y_hand = player_height + cue_parameters[cue_emitter_state][CueSelector.HAND]["yoffset"]
	var y_head = player_height + cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"]
	var x = 0
	var x_head = 0
	
	var hand_delay = 0.15
	var dd_df = fly_distance/fly_time
	
	create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	if cue_parameters[cue_emitter_state][CueSelector.HAND]["has_hand"]:
		create_and_attach_cue(current_time,"left", x-cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time, -hand_delay * dd_df)
		create_and_attach_cue(current_time, "right", x+cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time, -hand_delay * dd_df)


############################# CRUNCH ######################################

var crunch_state_model
var crunch_state = CrunchState.HEAD

var medium_hold_high = true #Medium hold alternates between high and low

func handle_crunch_cues(current_time, target_time, cue_emitter_state):
	switch_floor_sign(current_time,"none")
	
	
	crunch_state = state_transition (crunch_state, crunch_state_model)	
	var node_selector = rng.randi()%100
	
	var rot = (rng.randf()-0.5) * deg2rad(cue_parameters[cue_emitter_state][CueSelector.HAND]["rotation_range"])
		
	var x_head = rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"] - cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"]/2
	var y_head = cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["yrange"]
	
	var rot_distance_reduction = max(0.4, 1.0 - (1.5 * abs(rot)/PI))
	var y_hand = rot_distance_reduction *  cue_parameters[cue_emitter_state][CueSelector.HAND]["yoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HAND]["yrange"]
	var x = rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HAND]["xrange"] - cue_parameters[cue_emitter_state][CueSelector.HAND]["xrange"]/2
	
	print ("Crunch Spread %.2f"%(cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"]))

	var spread = cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"]/2.0+rng.randf()*cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"]
	var t = Transform(Vector3(1,0,0), Vector3(0,1,0), Vector3(0,0,1), Vector3(0,0,0)).rotated(Vector3(0,0,1), rot)
	var tmp = t.xform(Vector3(x+spread,y_hand,0))		
	
	if crunch_state == CrunchState.HAND:
		create_and_attach_cue(current_time,"right", tmp.x, tmp.y, target_time,0,0,"",null,null,0.5)
		tmp = t.xform(Vector3(x-spread,y_hand,0))		
		create_and_attach_cue(current_time,"left", tmp.x,tmp.y, target_time,0,0,"",null,null,0.5)
	elif crunch_state == CrunchState.HEAD:
		create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	elif crunch_state == CrunchState.MEDIUM_HOLD:
		x_head = 0
		if medium_hold_high:
			y_head = player_height/1.8
		else:
			y_head = player_height/3.1
		medium_hold_high = not medium_hold_high
			
		create_and_attach_cue(current_time,"head", x_head, y_head, target_time, 0,0,"", null,null, 0.4)
		create_and_attach_cue(current_time + 0.1,"right", x_head + player_height/5.0, y_head, target_time+0.1,0,0,"",null,null,0.3)
		create_and_attach_cue(current_time + 0.1,"left", x_head - player_height/5.0, y_head, target_time+0.1,0,0,"",null,null,0.3)	

############################# PUSHUP ######################################

var pushup_state = PushupState.REGULAR
var pushup_distribution = {}
var pushup_state_model

func handle_pushup_cues(current_time, target_time, cue_emitter_state):
	switch_floor_sign(current_time,"hands")
	
	if rebalance_exercises:
		pushup_state = state_transition (pushup_state, pushup_state_model, pushup_distribution)
	else:
		pushup_state = state_transition (pushup_state, pushup_state_model)
		
	var node_selector = rng.randi()%100

	var y_head = cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["yrange"]
	var x = 0.3 + rng.randf() * 0.25
	var x_head = rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"] - cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"]/2
	var y_hand = 0.3 + rng.randf() * 0.4
	
	if pushup_state == PushupState.REGULAR:
		create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	elif pushup_state == PushupState.LEFT_HAND:
			var n = create_and_attach_cue(current_time, "left", -x,y_hand, target_time, -hand_cue_offset,0,"onehanded")
	elif pushup_state == PushupState.RIGHT_HAND:
			var n = create_and_attach_cue(current_time,"right", x,y_hand, target_time, -hand_cue_offset,0,"onehanded")
	elif pushup_state == PushupState.LEFT_SIDEPLANK or pushup_state == PushupState.RIGHT_SIDEPLANK:
		#side plank
		x_head = 0
		x = 0
		y_head = player_height * 0.5
		y_hand = player_height * 0.9

		var hand_delay = 0.15
		var dd_df = fly_distance/fly_time				

		temporary_cue_space_extension = cue_parameters[cue_emitter_state]["sideplank_cue_space"]
				
		if pushup_state == PushupState.LEFT_SIDEPLANK:
			create_and_attach_cue(current_time,"head_left", x_head-0.3, y_head, target_time,0,0,"sideplank")
			create_and_attach_cue(current_time,"right", x, y_hand, target_time+hand_delay, -hand_delay * dd_df,0,"sideplank")
		else:
			create_and_attach_cue(current_time,"head_right", x_head+0.3, y_head, target_time,0,0,"sideplank")
			create_and_attach_cue(current_time,"left", x, y_hand, target_time + hand_delay, -hand_delay * dd_df,0,"sideplank")
		if cue_parameters[cue_emitter_state]["sideplank_has_pushup"]:
			var tmp = 3*temporary_cue_space_extension / 4.0
			create_and_attach_cue(current_time + tmp,"head", 0, cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"], target_time+tmp,0,0,"sideplank")
			temporary_cue_space_extension += 0.5


############################# BURPEE ######################################

enum BurpeeState {
	PUSHUP_HIGH = 0,
	PUSHUP_LOW = 1,
	JUMP = 2,
};	

var burpee_state_model = { BurpeeState.PUSHUP_LOW : { BurpeeState.JUMP: 100},
						BurpeeState.PUSHUP_HIGH : { BurpeeState.PUSHUP_LOW: 100},
						BurpeeState.JUMP : { BurpeeState.PUSHUP_HIGH: 100},
					};
	
var burpee_state = BurpeeState.JUMP

func handle_burpee_cues(current_time, target_time, cue_emitter_state):
	var length = cue_parameters[CueState.BURPEE]["burpee_length"]
	var time_offset = 0
	var x_head = 0
	switch_floor_sign(current_time,"hands")
	var y_head = cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"]
	create_and_attach_cue(current_time,"head", x_head, y_head, target_time)

	time_offset = 0.3*length

	y_head = 0.25
	create_and_attach_cue(current_time+time_offset,"head", x_head, y_head, target_time+time_offset)

	time_offset = 0.6*length

	switch_floor_sign(current_time+time_offset,"feet")
	y_head = player_height + jump_offset
	temporary_cue_space_extension = length

	create_and_attach_cue(current_time+time_offset,"head_extended", x_head, y_head, target_time+time_offset)
	var hand_delay = 0.15
	var dd_df = fly_distance/fly_time	
	var y_hand = y_head			
	if cue_parameters[cue_emitter_state][CueSelector.HAND]["has_hand"]:
		create_and_attach_cue(current_time+time_offset,"left", x_head-cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time+time_offset, -hand_delay * dd_df, 0, "burpee_hand")
		create_and_attach_cue(current_time+time_offset,"right", x_head+cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time+time_offset, -hand_delay * dd_df, 0, "burpee_hand")		
	
#	if exercise_changed:
#		burpee_state = BurpeeState.JUMP
#
#	burpee_state = state_transition (burpee_state, burpee_state_model)
#	var y_head = 0
#	var x_head = 0
#
#	if burpee_state == BurpeeState.PUSHUP_HIGH:
#		switch_floor_sign(current_time,"hands")
#		y_head = cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"]
#	elif burpee_state == BurpeeState.PUSHUP_LOW:
#		switch_floor_sign(current_time,"hands")
#		y_head = 0.3
#		temporary_cue_space_extension = 1.0
#	else:
#		switch_floor_sign(current_time,"feet")
#		y_head = player_height + jump_offset
#		temporary_cue_space_extension = 1.0
#
#	if burpee_state == BurpeeState.JUMP:
#		create_and_attach_cue(current_time,"head_extended", x_head, y_head, target_time)
#		var hand_delay = 0.15
#		var dd_df = fly_distance/fly_time	
#		var y_hand = y_head			
#		if cue_parameters[cue_emitter_state][CueSelector.HAND]["has_hand"]:
#			create_and_attach_cue(current_time,"left", x_head-cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time+hand_delay, -hand_delay * dd_df, 0, "burpee_hand")
#			create_and_attach_cue(current_time,"right", x_head+cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"], y_hand, target_time+hand_delay, -hand_delay * dd_df, 0, "burpee_hand")		
#	else:
#		create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	

############################# YOGA ######################################

enum YogaState {
	LEFT = 0,
	RIGHT = 1,
};	

var yoga_state_model = { YogaState.LEFT : { YogaState.RIGHT: 100},
						YogaState.RIGHT : { YogaState.LEFT: 100},
					};
var yoga_state = YogaState.LEFT

func handle_yoga_cues(current_time, target_time, cue_emitter_state):
	switch_floor_sign(current_time,"feet")
	yoga_state = state_transition(yoga_state, yoga_state_model)

	if yoga_state == YogaState.LEFT:
		create_and_attach_cue(current_time,"left_hold", -0.3*player_height, 0.85 * player_height, target_time, 0, target_time+0.5)
	else:
		create_and_attach_cue(current_time,"right_hold", 0.3*player_height, 0.85 * player_height, target_time, 0, target_time+0.5)



############################# STAND ######################################

var stand_state
var stand_state_model
var stand_state_model_changed = false
func handle_stand_cues(current_time,target_time,cue_emitter_state):
	var last_stand_state = stand_state
	switch_floor_sign(current_time,"feet")
	stand_state = state_transition(stand_state, stand_state_model)

	if last_stand_state != stand_state:
		stand_state_model_changed = true
	
	#Skip one cue after a double swing or windmill stretch
	if (last_stand_state == StandState.DOUBLE_SWING or last_stand_state == StandState.WINDMILL_TOE )and last_stand_state != stand_state:
		return
		
	if stand_state == StandState.DOUBLE_SWING:
		handle_double_swing_cues(current_time, target_time, player_height*0.8, cue_emitter_state, stand_state_model_changed)
	elif stand_state == StandState.WINDMILL_TOE:
		handle_windmill_touch_cues(current_time, target_time, cue_emitter_state, stand_state_model_changed)
	else:
		handle_stand_cues_regular(current_time, target_time, cue_emitter_state)

	stand_state_model_changed = false

func get_double_swing_y(y_hand_base, high):
	var y_hand
	var base = current_difficulty / 3.0
	var delta = 1.0 - base

	if high:
		y_hand = y_hand_base - (delta * rng.randf() + base) * cue_parameters[cue_emitter_state][CueSelector.HAND]["yrange"]/2.0
	else:
		y_hand = y_hand_base + (delta * rng.randf() + base) * cue_parameters[cue_emitter_state][CueSelector.HAND]["yrange"]/2.0
	return y_hand

var last_double_swing_left = true	
var last_double_swing_high = true
func handle_double_swing_cues(current_time, target_time, y_hand_base, cue_emitter_state, state_change = false):	
	var x_hand = cue_parameters[cue_emitter_state][CueSelector.HAND]["double_swing_spread"]

	if state_change:
		last_double_swing_high = (randi()%2 == 0)
		last_double_swing_left = (randi()%2 == 0)
	if not last_double_swing_left:
		x_hand = -x_hand
	
	var y_hand = get_double_swing_y(y_hand_base, last_double_swing_high)
	last_double_swing_high = not last_double_swing_high

	create_and_attach_cue(current_time,"left", x_hand-0.1, y_hand, target_time, -hand_cue_offset, 0, "double_swing", null, -1.0, 0.5)
	create_and_attach_cue(current_time,"right", x_hand+0.1, y_hand, target_time, -hand_cue_offset, 0, "double_swing", null, -1.0, 0.5)

	if min_cue_space >= 0.5:	
		var double_punch_delay = 0.4
		
		y_hand = get_double_swing_y(y_hand_base, last_double_swing_high)
		last_double_swing_high = not last_double_swing_high
		
		create_and_attach_cue(current_time+double_punch_delay,"left", -x_hand-0.1, y_hand, target_time+double_punch_delay, -hand_cue_offset, 0, "double_swing", null, -1.0, 0.5)
		create_and_attach_cue(current_time+double_punch_delay,"right", -x_hand+0.1, y_hand, target_time+double_punch_delay, -hand_cue_offset, 0, "double_swing", null, -1.0, 0.5)
	else:
		last_double_swing_left = not last_double_swing_left
	
var windmill_left = true
var windmill_high = true
func handle_windmill_touch_cues(current_time, target_time, cue_emitter_state, state_change):
	var y_head = player_height 

	if state_change:
		#Prevent windmills from always going in the same direction
		windmill_high = (randi()%2 == 0)
		windmill_left = (randi()%2 == 0)

	var y_hand1 = player_height
	var y_hand2 = player_height*1.2
	var y_hand3 = player_height*0.6
	
	if not windmill_high:
		y_hand1 = player_height*0.8
		y_hand2 = player_height*0.6
		y_hand3 = player_height
	
	var x_hand = player_height * 0.4
	#create_and_attach_cue(current_time,"head", 0, y_head, target_time)
	
	var double_punch_delay = 0.5

	if windmill_left:
		var n_id = create_and_attach_cue(current_time,"left", -x_hand,y_hand1, target_time, -hand_cue_offset)
		var n2_id = create_and_attach_cue(current_time+double_punch_delay*0.5,"left", 0.1666*x_hand, y_hand2, target_time+double_punch_delay , -hand_cue_offset,0,"",n_id)
		var n3_id = create_and_attach_cue(current_time+double_punch_delay,"left", x_hand, y_hand3, target_time+double_punch_delay , -hand_cue_offset,0,"",n2_id)
	else:
		var n_id = create_and_attach_cue(current_time,"right", x_hand,y_hand1, target_time, -hand_cue_offset)
		var n2_id = create_and_attach_cue(current_time+double_punch_delay*0.5,"right", -0.1666*x_hand, y_hand2, target_time+double_punch_delay , -hand_cue_offset,0,"",n_id)
		var n3_id = create_and_attach_cue(current_time+double_punch_delay,"right", -x_hand, y_hand3, target_time+double_punch_delay , -hand_cue_offset,0,"",n2_id)

	windmill_left = not windmill_left
	windmill_high = not windmill_high
	temporary_cue_space_extension = double_punch_delay + 0.25


		
func handle_stand_cues_regular(current_time, target_time, cue_emitter_state):
	var node_selector = rng.randi()%100
	
	var y_hand = player_height + cue_parameters[cue_emitter_state][CueSelector.HAND]["yoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HAND]["yrange"]
	var y_head = player_height + cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"]
	var x = sign(randf()-0.5) * (cue_parameters[cue_emitter_state][CueSelector.HAND]["xoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HAND]["xrange"])
	var x_head = rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"] - cue_parameters[cue_emitter_state][CueSelector.HEAD]["xrange"]/2.0
	
	if cue_selector == CueSelector.HAND and node_selector < 20:
		cue_selector = CueSelector.HEAD
	elif cue_selector == CueSelector.HEAD and node_selector < 50:	
		cue_selector = CueSelector.HAND
	
	var double_punch = rng.randf() < 0.5
	var double_punch_delay = 0.25
	
	if cue_selector == CueSelector.HAND:
		if node_selector < 50:	
			var n_id = create_and_attach_cue(current_time,"left", -x,y_hand, target_time, -hand_cue_offset)
			if double_punch:
				var n2 = create_and_attach_cue(current_time+double_punch_delay,"left", -x*rng.randf(),(y_hand+player_height*(0.5+rng.randf()*0.2))/2, target_time+double_punch_delay , -hand_cue_offset,0,"",n_id)
		else:			
			var n_id = create_and_attach_cue(current_time,"right", x,y_hand, target_time, -hand_cue_offset)
			if double_punch:
				var n2 = create_and_attach_cue(current_time+double_punch_delay,"right", x*rng.randf(),(y_hand+player_height*(0.5+rng.randf()*0.2))/2, target_time+double_punch_delay , -hand_cue_offset,0,"",n_id)
	else:
		if ducking_mode and rng.randf() < stand_avoid_head_cue:
			temporary_cue_space_extension = 1.0
			if abs(x_head) > 0.3:
				#If the head is far out, make the blockade diagonal
				create_and_attach_cue(current_time,"head_avoid", x_head-sign(x_head)*0.4, y_head, target_time)
				create_and_attach_cue(current_time,"head_avoid", x_head-sign(x_head)*0.2, y_head, target_time, 0.4)
			else:
				#Otherwise make it straight
				create_and_attach_cue(current_time,"head_avoid", x_head-0.3, y_head, target_time, 0.8)
				create_and_attach_cue(current_time,"head_avoid", x_head+0.3, y_head, target_time, 0.8)
				
			create_and_attach_cue(current_time,"head_avoid", x_head, y_head, target_time, 0.8)
		create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	
	
############################# SQUAT ######################################

var squat_state = SquatState.HEAD
var squat_state_model
var squat_state_model_change = false
	
func handle_squat_cues(current_time, target_time, cue_emitter_state):
	switch_floor_sign(current_time,"feet")
	var last_squat_state = squat_state
	squat_state = state_transition (squat_state, squat_state_model)
	
	if last_squat_state != squat_state:
		squat_state_model_change = true
	
	#Skip one cue after a double swing stretch
	if last_squat_state == SquatState.DOUBLE_SWING and last_squat_state != squat_state:
		return

	if squat_state == SquatState.DOUBLE_SWING:
		handle_double_swing_cues(current_time, target_time, player_height/2.0, cue_emitter_state, squat_state_model_change)
	else:
		handle_squat_cues_regular(current_time, target_time, cue_emitter_state)

	squat_state_model_change = false

var is_high_squat = false	
func handle_squat_cues_regular(current_time, target_time, cue_emitter_state):
	var node_selector = rng.randi()%100
	var y_head

	if is_high_squat:
		#Put it in the uper 25% range
		y_head = player_height/2 + cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + (cue_parameters[cue_emitter_state][CueSelector.HEAD]["yrange"] - rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["yrange"] * 0.25 )
	else:
		#Put it in the lower 25% range
		y_head = player_height/2 + cue_parameters[cue_emitter_state][CueSelector.HEAD]["yoffset"] + rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HEAD]["yrange"] * 0.25
	is_high_squat = not is_high_squat

	var y_hand = y_head + (rng.randf() * 0.4 - 0.2)
	var x = 0.3 + rng.randf() * 0.45
	var x_head = rng.randf() * cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"] - cue_parameters[cue_emitter_state][CueSelector.HAND]["xspread"]/2
	
	if squat_state == SquatState.LEFT_HAND:
		var n = create_and_attach_cue(current_time,"left", -x,y_hand, target_time, -hand_cue_offset)
	elif squat_state == SquatState.RIGHT_HAND:
		var n = create_and_attach_cue(current_time,"right", x,y_hand, target_time, -hand_cue_offset)
	else:
		create_and_attach_cue(current_time,"head", x_head, y_head, target_time)
	
func get_state_transition_pause(old_state, new_state):
	var retVal = GameVariables.default_state_transition_pause
	var transition = "%d-%d"%[old_state, new_state]
	if adjust_state_transition_pause and transition in GameVariables.state_transition_time:
		retVal = GameVariables.state_transition_time[transition]
	return retVal


#####################
func evaluate_beat(current_time, target_time):
	if last_emit + min_cue_space < current_time and last_state_change + state_transition_pause < current_time:		
		if last_emit + temporary_cue_space_extension <  current_time:
			temporary_cue_space_extension = 0
			emit_cue_node(current_time, target_time)
			last_emit = current_time



