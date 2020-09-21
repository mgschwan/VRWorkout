extends StaticBody

signal selected(exercise_list, slot_number)

export var exercise_name = "test"
export(int) var slot_number = 0
export(String) var active_marker = ""

var exercise_list = []
var timestamp = ""
var score = {}

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
			score = tmp.get("score_best", {})
	return retVal
	
func save_exercise_slot(id, cue_list):
	var f = File.new()
	var err = f.open("user://stored_slot_%d.json"%id, File.WRITE)
	if err == OK:
		var t = OS.get_datetime()
		print ("Saving exercise")
			
		var tmp = {"timestamp": "%02d.%02d.%04d %02d:%02d:%02d"%[t["day"],t["month"],t["year"],t["hour"],t["minute"],t["second"]],
				   "cue_list": cue_list,
				   "score_best": {"points": score.get("points",0), "score": score.get("score",0)}}
		var data = JSON.print(tmp)
		f.store_string(data)
		f.close()

func update_widget():
	if exercise_list:
		get_node("TextElement").print_info("Slot #%d\nCreated: %s\n\nBest:\nScore: %.2f\nPoints: %.2f"%[slot_number, timestamp, score.get("score",0), score.get("points",0)])
	else:
		get_node("TextElement").print_info("Slot #%d\nEmpty"%[slot_number])

func _ready():
	var exercises = ""
	exercise_list = load_exerise_slot(slot_number)
	if GameVariables.game_mode == GameVariables.GameMode.STORED and GameVariables.selected_game_slot == slot_number:
		print ("Saving game slot")
		if score["points"] < GameVariables.game_result.get("points",0):
			score["points"] = GameVariables.game_result.get("points",0)
			score["score"] = GameVariables.game_result.get("vrw_score",0)
			save_exercise_slot(slot_number, exercise_list)
			GameVariables.game_mode = GameVariables.GameMode.STANDARD

	update_widget()

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation
		
func touched_by_controller(obj,root):
	print ("Slot selected")
	get_node("AudioStreamPlayer").play(0.0)
	mark_active()
	emit_signal("selected", exercise_list, slot_number)

func _on_SaveButton_selected():
	exercise_list = GameVariables.cue_list.duplicate()
	score["points"] = GameVariables.game_result.get("points",0)
	score["score"] = GameVariables.game_result.get("vrw_score",0)
	GameVariables.selected_game_slot = slot_number
	save_exercise_slot(slot_number, GameVariables.cue_list)
	load_exerise_slot(slot_number)
	update_widget()
