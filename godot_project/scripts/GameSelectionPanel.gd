extends Spatial

signal workout_selected(collection, achievements)
signal exercise_set_selected(collection)
signal challenge_selected(exercise_list, slot_number, level_statistics_data)
signal onboarding_selected()

func _on_main_exercise_set_selected(collection):
	emit_signal("exercise_set_selected",collection)

func _on_main_workout_selected(collection, achievements):
	emit_signal("workout_selected",collection,achievements)

func _on_main_challenge_selected(exercise_list, slot_number, level_statistics_data):
	emit_signal("challenge_selected",exercise_list,slot_number, level_statistics_data)

func _on_main_onboarding_selected():
	print ("Onboarding selected")
	emit_signal("onboarding_selected")
