extends Control

signal workout_selected(collection, achievements)
signal exercise_set_selected(collection)
signal challenge_selected(exercise_list, slot_number, level_statistics_data)
signal onboarding_selected()

signal content_changed()

var gu = GameUtilities.new()

var exercise_sets = GameVariables.exercise_collections
var exercise_names = GameVariables.exercise_collection_names

var workouts = GameVariables.predefined_exercises
var workout_names = workouts.keys()
var workout_achievements = GameVariables.predefined_achievements

var challenges = Array()
var challenge_names = Array()

func get_exercise_set_description(nr):
	var collection = exercise_sets[nr]
	var exercises = ""
	for i in collection:
		exercises += i["description"] +": "
		if i["value"]:
			exercises += "Yes"
		else:
			exercises += "No"
		exercises += " - "
	return exercises

func get_workout_description(nr):
	var exercises = ""
	var collection = workouts[workout_names[nr]]
	for i in collection:
		exercises += i[0] +": %d"%i[1]
		exercises += " - "

	var possible_achievements = ""
	var achievements_list = gu.get_possible_workout_achievements(workout_names[nr])
	var tmp = {}
	for a in achievements_list:
		tmp[a.get("achievement","")] = 0
	
	for a in tmp.keys():
		possible_achievements += a
		possible_achievements += " - "
	return "%s\n\nYou can achieve:\n\n%s"%[exercises, possible_achievements]	
	
func setup_challenges():
	var tmp = gu.load_challenges()	
	challenges.clear()
	challenge_names.clear()
	for k in tmp:
		var name = ""
		if tmp[k].is_local:
			name = k
		else:
			name = "Online %s"%tmp[k].get("timestamp","")
		challenge_names.append(name)
		challenges.append(tmp[k])
	

func sync_online_challenges():
	var slot_index = 0
	for handle in GameVariables.challenge_slots:
		var public_handle = GameVariables.challenge_slots.get("%d"%slot_index, "")
		print ("Slot #%d %s"%[slot_index, public_handle])
		if public_handle:
			var result = Dictionary()			
			yield(get_tree().current_scene.get_node("RemoteInterface").get_public_dataobject(public_handle, result), "completed")
			var data = result.get("dataobject", null)			
			if data:
				var challenge_handle = public_handle
				var exercise_list = data.get("cue_list",[])
				var duration = data.get("duration",0)
				var additional_data = {}
				additional_data["song"] = data.get("song","")
				additional_data["message"] = data.get("message","")
				gu.save_challenge(challenge_handle, exercise_list, duration, challenge_handle, additional_data, Dictionary(), false)
		slot_index += 1	

	
func update_challenge_widget():
	$TabContainer/Challenges/ItemList.clear()
	for i in range(len(challenge_names)):
		$TabContainer/Challenges/ItemList.add_item(challenge_names[i])		

	
	
func update_widget():
	$"TabContainer/Exercise sets/ItemList".clear()
	for i in range(len(exercise_names)):
		$"TabContainer/Exercise sets/ItemList".add_item(exercise_names[i])

	$TabContainer/Workouts/ItemList.clear()
	for i in range (len(workout_names)):
		$TabContainer/Workouts/ItemList.add_item(workout_names[i])
	
	setup_challenges()
	update_challenge_widget()
	
	emit_signal("content_changed")

func _ready():
	sync_online_challenges()
	update_widget()

func _on_ExerciseSets_item_selected(index):
	var description = get_exercise_set_description(index)
	$"TabContainer/Exercise sets/Info".bbcode_text = "Description:\n\n%s"%description
	emit_signal("exercise_set_selected",exercise_sets[index])
	emit_signal("content_changed")

func _on_Workout_item_selected(index):
	var description = get_workout_description(index)
	$"TabContainer/Workouts/Info".bbcode_text = "Description:\n\n%s"%description
	emit_signal("workout_selected",workouts[workout_names[index]], gu.get_possible_workout_achievements(workout_names[index]))
	emit_signal("content_changed")


func _on_Save_pressed():
	var exercise_list = GameVariables.cue_list.duplicate()
	var score = Dictionary()
	score["points"] = GameVariables.game_result.get("points",0)
	score["score"] = GameVariables.game_result.get("vrw_score",0)
	var additional_data = Dictionary()
	if len(GameVariables.level_statistics_data):
		additional_data["level_statistics_data"] = GameVariables.level_statistics_data
		
	var	duration = GameVariables.game_result.get("time",0)
	#	GameVariables.selected_game_slot = slot_number
	var t = OS.get_datetime()
	var id = "Local %02d.%02d.%04d %02d:%02d:%02d"%[t["day"],t["month"],t["year"],t["hour"],t["minute"],t["second"]]
	gu.save_challenge(id, exercise_list, duration, "", additional_data, score, true)
	update_widget()
	
func _on_Challenge_item_selected(index):
	var challenge = challenges[index]
	var score = challenge.get("score_best", Dictionary())
	$TabContainer/Challenges/Info.bbcode_text = "Best:\nPoints: %.2f\nScore: %.2f"%[score.get("points",0), score.get("score", 0)]
	
	var message = challenge.get("additional_data",Dictionary()).get("message","")
	$TabContainer/Challenges/Info.bbcode_text += "\n%s"%message
	
	var level_statistics_data = challenge.get("additional_data",Dictionary()).get("level_statistics_data",Dictionary())
	
	emit_signal("challenge_selected", challenge["cue_list"], challenge["id"], level_statistics_data)
	emit_signal("content_changed")


func _on_Onboarding_pressed():
	emit_signal("onboarding_selected")


func _on_TabContainer_tab_changed(tab):
	emit_signal("content_changed")

func _on_DeleteChallenge_confirmed():
	var items = $TabContainer/Challenges/ItemList.get_selected_items()
	if len(items) > 0:
		var delete_item = items[0]		
		if delete_item < len(challenges):
			var delete_id = challenges[delete_item].get("id",null)
			print ("Delete challenge with id: %s"%str(delete_id))
			if delete_id != null:
				gu.delete_challenge(delete_id)
				update_widget()

func _on_DeleteChallenge_pressed():
	var items = $TabContainer/Challenges/ItemList.get_selected_items()
	if len(items) > 0:
		$TabContainer/Challenges/Delete/ConfirmationDialog.popup()
