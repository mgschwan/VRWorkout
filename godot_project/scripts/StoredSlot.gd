extends StaticBody

signal selected(exercise_list)

export var exercise_name = "test"
export(int) var slot_number = 0
export(String) var active_marker = ""

var exercise_list = []

func load_exerise_slot(id):
	var retVal = []
	var f = File.new()
	var err = f.open("user://stored_slot_%d.json"%id, File.READ)
	if err == OK:
		var tmp = JSON.parse(f.get_as_text()).result
		f.close()
		if tmp:
			var timestamp = tmp.get("timestamp", 0)
			retVal = tmp.get("exercise_list", [])
	return retVal

func _ready():
	var exercises = ""
	exercise_list = load_exerise_slot(slot_number)
	get_node("TextElement").print_info("Slot #%d"%slot_number)

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation
		
func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	mark_active()
	emit_signal("selected", exercise_list)



