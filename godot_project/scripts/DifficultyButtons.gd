extends Spatial

var selected = "easy"

signal difficulty_selected(difficulty)

func _ready():
	update_widgets()


func update_widgets():
	get_node("Easy").show_selector( selected == "easy")
	get_node("Medium").show_selector( selected == "medium")
	get_node("Hard").show_selector( selected == "hard")
	get_node("Auto").show_selector( selected == "auto")
	get_node("Ultra").show_selector( selected == "ultra")

func select_difficulty(d):
	if d == -1:
		selected = "auto"
	elif d == 0:
		selected = "easy"
	elif d == 1:
		selected = "medium"
	elif d == 2:
		selected = "hard"
	elif d == 3:
		selected = "ultra"
	update_widgets()		


func _on_Button_selected(extra_arg_0):
	selected = extra_arg_0
	update_widgets()
	emit_signal("difficulty_selected", selected)
	
func enable_automatic (state):
	var autonode = get_node("Auto")
	if state:
		autonode.show()
		autonode.set_process(true)
	else:
		autonode.hide()
		autonode.set_process(false)
