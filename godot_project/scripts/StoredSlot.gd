extends StaticBody

signal selected(exercise_list)

export var exercise_name = "test"
export(int) var slot_number = 0
export(String) var active_marker = ""

var exercise_list = []
var timestamp = ""

func load_exerise_slot(id):
	var retVal = []
	var f = File.new()
	var err = f.open("user://stored_slot_%d.json"%id, File.READ)
	if err == OK:
		var tmp = JSON.parse(f.get_as_text()).result
		f.close()
		if tmp:
			timestamp = tmp.get("timestamp", "")
			retVal = tmp.get("cue_list", [])
	return retVal
	
func save_exercise_slot(id):
	exercise_list = GameVariables.cue_list.duplicate()
	var f = File.new()
	var err = f.open("user://stored_slot_%d.json"%id, File.WRITE)
	if err == OK:
		var t = OS.get_datetime()
		print ("Saving exercise")
		var tmp = {"timestamp": "%02d.%02d.%04d %02d:%02d:%02d"%[t["day"],t["month"],t["year"],t["hour"],t["minute"],t["second"]],
				   "cue_list": GameVariables.cue_list}
		var data = JSON.print(tmp)
		f.store_string(data)
		f.close()

func _ready():
	var exercises = ""
	exercise_list = load_exerise_slot(slot_number)
	if exercise_list:
		get_node("TextElement").print_info("Slot #%d\nEmpty"%[slot_number])
	else:
		get_node("TextElement").print_info("Slot #%d\n%s"%[slot_number, timestamp])

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation
		
func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	mark_active()
	emit_signal("selected", exercise_list)

func _on_SaveButton_selected():
	save_exercise_slot(slot_number)
