extends StaticBody


signal selected(collection)

export var exercise_name = "test"

var collection = []

func _ready():
	var exercises = ""
	if GameVariables.predefined_exercises.has(exercise_name):
		collection = GameVariables.predefined_exercises[exercise_name]
		for i in collection:
			exercises += i[0] +": %d"%i[1]
			exercises += "\n"

	get_node("TextElement").print_info("Workout: %s\n\n%s"%[exercise_name,exercises])

func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected", collection)



