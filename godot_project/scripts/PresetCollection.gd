extends StaticBody


signal selected(collection)

export var exercise_name = "test"
export(String) var active_marker = ""

var collection = []

func _ready():
	var exercises = ""
	if GameVariables.predefined_exercises.has(exercise_name):
		collection = GameVariables.predefined_exercises[exercise_name]
		for i in collection:
			exercises += i[0] +": %d"%i[1]
			exercises += "\n"

	get_node("TextElement").print_info("Workout: %s\n\n%s"%[exercise_name,exercises])

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation
		
func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	mark_active()
	emit_signal("selected", collection)



