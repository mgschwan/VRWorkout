extends StaticBody


signal selected(collection)

export(int) var exercise_nr = 0 
export(String) var exercise_name = ""
export(String) var active_marker = ""


var collection


func _ready():
	collection = GameVariables.exercise_collections[exercise_nr]
	var exercises = ""
	for i in collection:
		exercises += i["description"] +": "
		if i["value"]:
			exercises += "Yes"
		else:
			exercises += "No"
		exercises += "\n"

	get_node("TextElement/Viewport/CanvasLayer/Label").bbcode_text = "Exercise: %s\n\n%s"%[exercise_name,exercises]

	#get_node("TextElement").print_info("Exercise: %s\n\n%s"%[exercise_name,exercises])

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation

func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	emit_signal("selected", collection)
	mark_active()



