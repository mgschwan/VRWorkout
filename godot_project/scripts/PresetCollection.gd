extends StaticBody


export(String) var header_logo = ""

signal selected(collection, achievements)

export var exercise_name = "test"
export(String) var active_marker = ""
export(String) var achievements = ""

var collection = Array()
var achievements_list = Array()

func _ready():
	var exercises = ""
	if GameVariables.predefined_exercises.has(exercise_name):
		collection = GameVariables.predefined_exercises[exercise_name]
		for i in collection:
			exercises += i[0] +": %d"%i[1]
			exercises += " - "
	var possible_achievements = ""
	if GameVariables.predefined_achievements.has(achievements):
		achievements_list = GameVariables.predefined_achievements[achievements]
		var tmp = {}
		for a in achievements_list:
			tmp[a.get("achievement","")] = 0
		
		for a in tmp.keys():
			possible_achievements += a
			possible_achievements += " - "
	
	get_node("TextElement/Viewport/CanvasLayer/Label").bbcode_text = "[img]%s[/img]Workout: %s\n\n%s\n\nYou can achieve:\n\n%s"%[header_logo,exercise_name,exercises, possible_achievements]

func mark_active():
	var node = get_parent().get_node(active_marker)
	if node:
		node.show()
		node.translation = self.translation
		
func touched_by_controller(obj,root):
	get_node("AudioStreamPlayer").play(0.0)
	mark_active()
	emit_signal("selected", collection, achievements_list)



