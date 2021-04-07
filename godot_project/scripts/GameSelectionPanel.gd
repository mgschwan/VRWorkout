extends Spatial

signal workout_selected(collection, achievements)
signal exercise_set_selected(collection)

func _on_main_exercise_set_selected(collection):
	emit_signal("exercise_set_selected",collection)

func _on_main_workout_selected(collection, achievements):
	emit_signal("workout_selected",collection,achievements)
