extends Spatial


func update_widgets():
	if ProjectSettings.get("game/hold_cues"):
		$Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed = ProjectSettings.get("game/hold_cues")
	else:
		$Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed = false
	if ProjectSettings.get("game/exercise/parcour"):
		$Viewport/CanvasLayer/Parcour/ParcourButton.pressed = ProjectSettings.get("game/exercise/parcour")
	else:
		$Viewport/CanvasLayer/Parcour/ParcourButton.pressed = false
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _ready():
	update_widgets()
	
	


func _on_HoldCueButton_pressed():
	ProjectSettings.set("game/hold_cues", $Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed)
	update_widgets()


func _on_ParcourButton_pressed():
	ProjectSettings.set("game/exercise/parcour", $Viewport/CanvasLayer/Parcour/ParcourButton.pressed)
	update_widgets()


func _on_Youtube_pressed():
	var link = ProjectSettings.get("application/config/youtube_link")
	OS.shell_open(link)
