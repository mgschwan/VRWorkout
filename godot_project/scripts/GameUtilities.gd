extends Object

class_name GameUtilities

func seconds_to_timestring(total):
	var minutes = int(total/60)
	var seconds = int(total)%60
	return "%02d:%02d"%[minutes,seconds]

func get_device_id():
	return OS.get_unique_id()
	
func disable_all_exercises():
	ProjectSettings.set("game/beast_mode", false)
	ProjectSettings.set("game/exercise/jump", false)
	ProjectSettings.set("game/exercise/stand", false)
	ProjectSettings.set("game/exercise/squat", false)
	ProjectSettings.set("game/exercise/pushup", false)
	ProjectSettings.set("game/exercise/crunch", false)
	ProjectSettings.set("game/exercise/burpees", false)
	ProjectSettings.set("game/exercise/duck", false)
	ProjectSettings.set("game/exercise/sprint", false)
	ProjectSettings.set("game/exercise/kneesaver", false)
	ProjectSettings.set("game/exercise/yoga", false)

func set_exercise_collection(collection):
	disable_all_exercises()
	for e in collection:
		ProjectSettings.set(e["setting"], e["value"])

func deactivate_node(node):
	node.hide()
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	node.set_process_unhandled_key_input(false)

func activate_node(node):
	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)
	node.set_process_unhandled_input(true)
	node.set_process_unhandled_key_input(true)
	node.show()
	
	
#Stores a config dict to disk
func store_persistent_config(location, parameters):
	var config_file = File.new()
	var error = config_file.open(location, File.WRITE)	
	if error == OK:
		var tmp = JSON.print(parameters)
		config_file.store_string(tmp)
		config_file.close()
		print ("Config saved")
	else: 
		print ("Could not save config")

	
func load_persistent_config(location):
	var config_file = File.new()
	var error = config_file.open(location, File.READ)
	var parameters = {}
	
	if error == OK:
		var tmp = JSON.parse(config_file.get_as_text()).result
		config_file.close()
		parameters = tmp
		print ("Config loaded")
	else: 
		print ("Could not open config")

	return parameters

func apply_config_parameters(parameters):
	for parameter in parameters:
		ProjectSettings.set(parameter, parameters[parameter])

func load_audio_resource(filename):
	var resource = null
	
	if filename.find("res://") == 0:
		resource = ResourceLoader.load(filename)
	else:
		var f = File.new()
		
		if  f.file_exists(filename):
			#print ("External resource exists")
			f.open(filename, File.READ)
			var buffer = f.get_buffer(f.get_len())
			if filename.ends_with(".mp3"):
				resource = AudioStreamMP3.new()
			else:
				resource = AudioStreamOGGVorbis.new()
			resource.data = buffer
		else:
			print ("External resource does not exist")

	return resource


func update_current_headset_energy(meters_per_second):
	var energy_adjustment_factor = 1.0
	if GameVariables.player_exercise_state == GameVariables.CueState.BURPEE or \
		GameVariables.player_exercise_state == GameVariables.CueState.PUSHUP or \
		GameVariables.player_exercise_state == GameVariables.CueState.CRUNCH:
			energy_adjustment_factor = 3.0
	elif GameVariables.player_exercise_state == GameVariables.CueState.SQUAT:
		energy_adjustment_factor = 2.0
	elif GameVariables.player_exercise_state == GameVariables.CueState.JUMP:
		energy_adjustment_factor = 2.5
	elif GameVariables.player_exercise_state == GameVariables.CueState.SPRINT:
		energy_adjustment_factor = 2.0

	GameVariables.current_headset_energy = GameVariables.current_headset_energy*0.4 + 0.6 * energy_adjustment_factor * meters_per_second

func update_current_controller_energy(meters_per_second):
	var energy_adjustment_factor = 1.0
	if GameVariables.player_exercise_state == GameVariables.CueState.BURPEE or \
		GameVariables.player_exercise_state == GameVariables.CueState.PUSHUP or \
		GameVariables.player_exercise_state == GameVariables.CueState.CRUNCH:
			energy_adjustment_factor = 3.0
	elif GameVariables.player_exercise_state == GameVariables.CueState.SQUAT:
		energy_adjustment_factor = 1.0
	elif GameVariables.player_exercise_state == GameVariables.CueState.JUMP:
		energy_adjustment_factor = 2.5
	elif GameVariables.player_exercise_state == GameVariables.CueState.SPRINT:
		energy_adjustment_factor = 0.2

	GameVariables.current_controller_energy = GameVariables.current_controller_energy*0.4 + 0.6 * energy_adjustment_factor * meters_per_second

func get_current_energy():
	return(GameVariables.current_headset_energy*GameVariables.headset_energy_factor + GameVariables.current_controller_energy*GameVariables.controller_energy_factor)

#Keep track of each debounced button and return true if the click should be
#valid
var tracked_objects = Dictionary()
func double_tap_debounce(obj, limit=0.2):
	var valid = false
	var obj_id = self.get_instance_id()
	var last_click = tracked_objects.get(obj_id, 0)
	var delta = float(OS.get_ticks_msec()-last_click)/1000.0
	if delta > limit:
		valid = true
		tracked_objects[obj_id] = OS.get_ticks_msec()
	return valid

#Get song name from path
func get_song_name(value):
	var tmp = ""
	if typeof(value) == TYPE_REAL or typeof(value) == TYPE_INT:
		if value >= 0:
			tmp = "Freeplay %s"%(seconds_to_timestring(value))
		else:
			tmp = "Pause %s"%(seconds_to_timestring(-value))
	else:
		tmp = value.rsplit(".")[0].rsplit("/")[-1]
	return tmp.replace("_"," ")

func get_songfile_from_name(name, songs):
	var retVal = 0
	print ("Looking for song %s"%str(name))
	if typeof(name) == TYPE_REAL or typeof(name) == TYPE_INT:
		retVal = name
	else:
		for fname in songs:
			print ("Find song: %s vs %s"%[get_song_name(fname),name])
			if get_song_name(fname) == name:
				retVal = fname
				break
	return retVal
	
func get_song_list(path):
	var song_dict = {}
	var dir = Directory.new()
	var ec = dir.open(path)
	
	if ec == OK:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir():
				var fields = fname.split(".")
				print (str(fields))
				if fields and (fields[-1] == "ogg" or fields[-1] == "mp3" or fields[-1] == "import"):
					var tmpf = fname
					if fields[-1] == "import":
						tmpf = fname.rsplit(".",true,1)[0]
					var full_path = "%s/%s"%[dir.get_current_dir(),tmpf]
					song_dict[full_path] = get_song_name(full_path)
			fname = dir.get_next()
	return song_dict.keys()

#Create a string from the playlist
func readable_song_list(value):
	var song_names = ""
	for i in value:
		song_names += get_song_name(i) + " "
	return song_names

func insert_cue_sorted(ts, cue_data, cue_emitter_list):
	var selected_idx = 0
	for cidx in range(len(cue_emitter_list)):
		if ts < cue_emitter_list[cidx][0]:
			break
		selected_idx = cidx + 1
	cue_emitter_list.insert(selected_idx, [ts, cue_data])

#Disconnect all connections for a certain signal
func disconnect_all_connections(node, signal_):
	print ("Disconnect: %s -> %s"%[str(node), str(signal_)])
	var connections = node.get_signal_connection_list(signal_)
	for s in connections:
		 node.disconnect(s["signal"], s["target"], s["method"])

func merge_dicts(a,b):
	var result = Dictionary()
	for key in a:
		result[key] = a[key]
	for key in b:
		result[key] = b[key]
	return result

func get_wall_time_str():
	var t = OS.get_time()
	return "%02d:%02d"%[t["hour"],t["minute"]]

func build_workout_statistic(data):
	var statistic = {}
	var heartrate = []
	var hr_total = 0
	var hr_max = 0
	var hr_avg = 0
	var difficulty_avg = 0
	var difficulty_sum = 0
	
	for id in data:
		var exercise = data[id].get("e","unknown/").split("/")[0]
		print ("Exercise %s"%exercise)
		var type = data[id].get("t","unknown")
		var tmp = data[id].get("h",false)
		var max_hit = data[id].get("mh",1.0)
		var difficulty = data[id].get("d",0.0)
		var hit = 0
		
		if typeof(tmp) == TYPE_REAL:
			hit = tmp
		elif tmp == true:
			hit = max_hit
		elif tmp == false:
			hit = 0.0

		if "avoid" in type:
			if hit > 0:
				hit = 0.0
			else:
				hit = max_hit
		var hr = data[id].get("hr",0)
		hr_total += hr
		hr_max = max(hr_max, hr)
		difficulty_sum += difficulty
		
		var starttime = data[id].get("st",0)
		statistic[exercise] = statistic.get(exercise, {"good": 0, "total": 0})
		if hit:
			statistic[exercise]["good"] += hit
		statistic[exercise]["total"] += max_hit
		heartrate.append([starttime, hr])

	if len(data) > 0:
		hr_avg = hr_total/float(len(data))
		difficulty_avg = difficulty_sum/float(len(data))


	return {"statistic": statistic,
			"heartrate": heartrate,
			"hr_max": hr_max, "hr_avg": hr_avg,
			"difficulty_avg": difficulty_avg,
			"calories": 0}
		
func upload_challenge(remoteinterface):    
       var challenge = {
               "cue_list": GameVariables.cue_list,
               "song": readable_song_list(GameVariables.current_song),
               "duration": GameVariables.game_result.get("time", 0),
               "score": GameVariables.game_result.get("vrw_score",0),
               "points": GameVariables.game_result.get("points",0)
       }
       print ("Current song: %s"%(readable_song_list(GameVariables.current_song)))
       remoteinterface.send_data(GameVariables.device_id,"challenge",challenge )

func hardness_level():
	var retVal = 0
	var e = get_current_energy()
	if e >= GameVariables.energy_level_low:
		retVal = 1
	if e >= GameVariables.energy_level_medium:
		retVal = 2
	if e >= GameVariables.energy_level_max:
		retVal = 3
	return retVal
	
func get_workout_collection(exercise_name):
	var collection = []
	if GameVariables.predefined_exercises.has(exercise_name):
		collection = GameVariables.predefined_exercises[exercise_name]
	return collection
			
func get_possible_workout_achievements(achievements):
	var achievements_list = []
	if GameVariables.predefined_achievements.has(achievements):
		achievements_list = GameVariables.predefined_achievements[achievements]
	return achievements_list	
	
	
	
	
	
		
