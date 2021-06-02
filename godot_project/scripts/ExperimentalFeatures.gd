extends Control

signal content_changed()
signal activate_feature(feature, value)

export var beast_mode = false



func _ready():
	var addresses = IP.get_local_addresses()
	$IPList.clear()
	for address in addresses:
		$IPList.add_item(address)
	update_widgets()

func update_widgets():
	if ProjectSettings.get("game/beast_mode"):
		$BeastMode/BeastModeButton.pressed = true
	else:
		$BeastMode/BeastModeButton.pressed = false
		
	if ProjectSettings.get("game/exercise/weights"):
		$Weights/WeightsButton.pressed = true
	else:
		$Weights/WeightsButton.pressed = false

func _on_BeastModeButton_pressed():
	beast_mode = not beast_mode
	get_tree().current_scene.set_beast_mode(beast_mode)

	ProjectSettings.set("game/beast_mode", $BeastMode/BeastModeButton.pressed)
	update_widgets()


func _on_WeightsButton_pressed():
	ProjectSettings.set("game/exercise/weights", $Weights/WeightsButton.pressed)
	emit_signal("activate_feature", "weights",  $Weights/WeightsButton.pressed)
	update_widgets()


func _on_StartCalibration_pressed():
	get_tree().current_scene.get_node("FBAvatarRoot/FBTAvatar").start_calibration = true
