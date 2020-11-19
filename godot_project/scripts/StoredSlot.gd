extends StaticBody

enum SlotType {
	STORED_SLOT = 0,
	ONLINE_CHALLENGE = 1	
}

var gu = GameUtilities.new()

export(SlotType) var type = SlotType.STORED_SLOT
export(bool) var save_button_active = true

signal selected(exercise_list, slot_number)

export var exercise_name = "test"
export(int) var slot_number = 0
export(String) var active_marker = ""

var exercise_list = []
var timestamp = ""
var score = {}
var duration = 0
var challenge_handle = null
var additional_data = {}


func file_location(id):
	if self.type == SlotType.ONLINE_CHALLENGE:
		return "user://challenge_slot_%d.json"%id
	return "user://stored_slot_%d.json"%id

func load_exerise_slot(id):
	var retVal = []
	var f = File.new()
	var err = f.open(file_location(id), File.READ)
	if err == OK:
		var tmp = JSON.parse(f.get_as_text()).result
		f.close()
		if tmp:
			timestamp = tmp.get("timestamp", "")
			retVal = tmp.get("cue_list", [])
			score = tmp.get("score_best", {})
			duration = tmp.get("duration",0)
			additional_data = tmp.get("additional_data",{})
			challenge_handle = tmp.get("handle", null)
	return retVal
	
func save_exercise_slot(id, cue_list):
	var f = File.new()
	var err = f.open(file_location(id), File.WRITE)
	if err == OK:
		var t = OS.get_datetime()
		print ("Saving exercise")
			
		var tmp = {"timestamp": "%02d.%02d.%04d %02d:%02d:%02d"%[t["day"],t["month"],t["year"],t["hour"],t["minute"],t["second"]],
				   "cue_list": cue_list,
				   "duration": duration,
				   "handle": challenge_handle,	
				   "additional_data": additional_data,
				   "score_best": {"points": score.get("points",0), "score": score.get("score",0)}}
		var data = JSON.print(tmp)
		f.store_string(data)
		f.close()

func update_widget():
	if self.type == SlotType.ONLINE_CHALLENGE:
		if duration:
			get_node("TextElement").print_info("Challenge #%d\n%s\n%s\n%s\n"%[slot_number, gu.seconds_to_timestring(duration), additional_data.get("song",""), additional_data.get("message","")])
		else:
			get_node("TextElement").print_info("Challenge #%d\nEmpty"%[slot_number])
	else:
		if exercise_list:
			get_node("TextElement").print_info("Slot #%d %s\nCreated: %s\n\nBest:\nScore: %.2f\nPoints: %.2f"%[slot_number,gu.seconds_to_timestring(duration), timestamp, score.get("score",0), score.get("points",0)])
		else:
			get_node("TextElement").print_info("Slot #%d\nEmpty"%[slot_number])

func _ready():
	var exercises = ""
	exercise_list = load_exerise_slot(slot_number)
	if save_button_active:
		gu.activate_node(get_node("SaveButton"))
	else:
		gu.deactivate_node(get_node("SaveButton"))
		
	if GameVariables.game_mode == GameVariables.GameMode.STORED and GameVariables.selected_game_slot == slot_number:
		GameVariables.game_mode = GameVariables.GameMode.STANDARD

		print ("Saving game slot")
		if score.get("points",0) < GameVariables.game_result.get("points",0):
			score["points"] = GameVariables.game_result.get("points",0)
			score["score"] = GameVariables.game_result.get("vrw_score",0)
			duration = GameVariables.game_result.get("time",0)
			save_exercise_slot(slot_number, exercise_list)
	
	if type == SlotType.ONLINE_CHALLENGE:
		var slot_index = slot_number - 1
		if slot_index >= 0:
			var public_handle = GameVariables.challenge_slots.get("%d"%slot_index, "")
			#print ("Slot #%d %s"%[slot_index, public_handle])
			if public_handle and public_handle != challenge_handle:
				var result = Dictionary()			
				yield(get_tree().current_scene.get_node("RemoteInterface").get_public_dataobject(public_handle, result), "completed")
				var data = result.get("dataobject", null)			
				if data:
					challenge_handle = public_handle
					exercise_list = data.get("cue_list",[])
					duration = data.get("duration",0)
					additional_data = {}
					additional_data["song"] = data.get("song","")
					additional_data["message"] = data.get("message","")
					save_exercise_slot(slot_number, exercise_list)

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
	GameVariables.current_challenge = challenge_handle
	emit_signal("selected", exercise_list, slot_number)

func _on_SaveButton_selected():
	if self.type == SlotType.STORED_SLOT:
		exercise_list = GameVariables.cue_list.duplicate()
		score["points"] = GameVariables.game_result.get("points",0)
		score["score"] = GameVariables.game_result.get("vrw_score",0)
		duration = GameVariables.game_result.get("time",0)
		GameVariables.selected_game_slot = slot_number
		save_exercise_slot(slot_number, GameVariables.cue_list)
		load_exerise_slot(slot_number)
		update_widget()
