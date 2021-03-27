extends Control

var gu = GameUtilities.new()

var exercise_sets = GameVariables.exercise_collections
var exercise_names = GameVariables.exercise_collection_names

var workouts = GameVariables.predefined_exercises
var workout_names = workouts.keys()
var workout_achievements = GameVariables.predefined_achievements

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
	

func _ready():
	$"TabContainer/Exercise sets/ItemList".clear()
	for i in range(len(exercise_names)):
		$"TabContainer/Exercise sets/ItemList".add_item(exercise_names[i])

	$TabContainer/Workouts/ItemList.clear()
	for i in range (len(workout_names)):
		$TabContainer/Workouts/ItemList.add_item(workout_names[i])



func _on_ExerciseSets_item_selected(index):
	var description = get_exercise_set_description(index)
	$"TabContainer/Exercise sets/Info".bbcode_text = "Description:\n\n%s"%description


func _on_Workout_item_selected(index):
	var description = get_workout_description(index)
	$"TabContainer/Workouts/Info".bbcode_text = "Description:\n\n%s"%description
