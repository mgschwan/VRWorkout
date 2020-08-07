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

#Get song name from path
func get_song_name(filename):
	var tmp = filename.rsplit(".")[0].rsplit("/")[-1]
	return tmp.replace("_"," ")



