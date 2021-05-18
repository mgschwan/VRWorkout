extends Spatial

var min_hr = 80
var hr_range = 90

var auto_enabled = false
var selected = "easy"

signal difficulty_selected(difficulty)

func _ready():
	update_widgets()


func update_widgets():
	if selected == "easy":
		$Viewport/CanvasLayer/Easy/Active.show()
	else:
		$Viewport/CanvasLayer/Easy/Active.hide()

	if selected == "medium":
		$Viewport/CanvasLayer/Medium/Active.show()
	else:
		$Viewport/CanvasLayer/Medium/Active.hide()

	if selected == "hard":
		$Viewport/CanvasLayer/Hard/Active.show()
	else:
		$Viewport/CanvasLayer/Hard/Active.hide()

	if selected == "ultra":
		$Viewport/CanvasLayer/Ultra/Active.show()
	else:
		$Viewport/CanvasLayer/Ultra/Active.hide()

	if selected == "auto":
		$Viewport/CanvasLayer/Auto/Active.show()
	else:
		$Viewport/CanvasLayer/Auto/Active.hide()
	
	
	if auto_enabled:
		var y_range = 188
		var y_offset = 60
		
		var current_hr = ProjectSettings.get("game/target_hr")
		var factor = 1.0 - (float(current_hr) - float(min_hr)) / float(hr_range)
		var value = clamp(int(factor*y_range), 0, y_range)
		
		$Viewport/CanvasLayer/Control/Label.rect_position.y = y_offset + value
		$Viewport/CanvasLayer/Control/Label.text = "Target\nHeartrate\n%d"%current_hr
	else:
		$Viewport/CanvasLayer/Control/Label.text = "No HR\nsensor\nconnected"
	
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE


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
	var autonode = get_node("Viewport/CanvasLayer/Auto")
	if state:
		auto_enabled = true
		autonode.show()
	else:
		auto_enabled = false
		autonode.hide()
	update_widgets()

func _on_Easy_pressed(extra_arg_0):
	$SoundEasy.play()
	_on_Button_selected(extra_arg_0)


func _on_Medium_pressed(extra_arg_0):
	$SoundMedium.play()
	_on_Button_selected(extra_arg_0)

func _on_Hard_pressed(extra_arg_0):
	$SoundHard.play()
	_on_Button_selected(extra_arg_0)
	
func _on_Auto_pressed(extra_arg_0):
	$SoundAuto.play()
	_on_Button_selected(extra_arg_0)

func _on_Ultra_pressed(extra_arg_0):
	$SoundUltra.play()
	_on_Button_selected(extra_arg_0)



func _on_Plus_pressed():
	var current_hr = ProjectSettings.get("game/target_hr")
	current_hr = clamp(current_hr+10, min_hr, min_hr+hr_range)
	ProjectSettings.set("game/target_hr", current_hr)
	update_widgets()


func _on_Minus_pressed():
	var current_hr = ProjectSettings.get("game/target_hr")
	current_hr = clamp(current_hr-10, min_hr, min_hr+hr_range)
	ProjectSettings.set("game/target_hr", current_hr)
	update_widgets()
