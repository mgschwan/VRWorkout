extends Control

signal content_changed()

func update_widgets():
	if ProjectSettings.get("game/exercise/hold_cues"):
		$HoldCue/HoldCueButton.pressed = true
	else:
		$HoldCue/HoldCueButton.pressed = false
		
	if ProjectSettings.get("game/exercise/parcour"):
		$Parcour/ParcourButton.pressed = true
	else:
		$Parcour/ParcourButton.pressed = false

	if ProjectSettings.get("game/exercise/pushup"):
		$Pushup/PushupButton.pressed = true
	else:
		$Pushup/PushupButton.pressed = false

	if ProjectSettings.get("game/hud_enabled"):
		$SafePushups/SafePushupsButton.pressed = true
	else:
		$SafePushups/SafePushupsButton.pressed = false

	if ProjectSettings.get("game/exercise/burpees"):
		$Burpee/BurpeeButton.pressed = true
	else:
		$Burpee/BurpeeButton.pressed = false

	if ProjectSettings.get("game/exercise/stand"):
		$Stand/StandButton.pressed = true
	else:
		$Stand/StandButton.pressed = false

	if ProjectSettings.get("game/exercise/duck"):
		$Ducking/DuckButton.pressed = true
	else:
		$Ducking/DuckButton.pressed = false

	if ProjectSettings.get("game/exercise/stand/windmill"):
		$Windmill/WindmillButton.pressed = true
	else:
		$Windmill/WindmillButton.pressed = false

	if ProjectSettings.get("game/exercise/stand/curved"):
		$CurvedCues/CurvedCuesButton.pressed = true
	else:
		$CurvedCues/CurvedCuesButton.pressed = false

	if ProjectSettings.get("game/equalizer"):
		$Equalizer/EqualizerButton.pressed = true
	else:
		$Equalizer/EqualizerButton.pressed = false

	if ProjectSettings.get("game/easy_transition"):
		$ExtendedTransition/ExtendedTransitionButton.pressed = true
	else:
		$ExtendedTransition/ExtendedTransitionButton.pressed = false

	if ProjectSettings.get("game/instructor"):
		$Instructor/InstructorButton.pressed = true
	else:
		$Instructor/InstructorButton.pressed = false

	if ProjectSettings.get("game/exercise/jump"):
		$Jump/JumpButton.pressed = true
	else:
		$Jump/JumpButton.pressed = false

	if ProjectSettings.get("game/exercise/sprint"):
		$Sprint/SprintButton.pressed = true
	else:
		$Sprint/SprintButton.pressed = false

	if ProjectSettings.get("game/exercise/squat"):
		$Squat/SquatButton.pressed = true
	else:
		$Squat/SquatButton.pressed = false

	if ProjectSettings.get("game/exercise/kneesaver"):
		$Kneesaver/KneesaverButton.pressed = true
	else:
		$Kneesaver/KneesaverButton.pressed = false

	if ProjectSettings.get("game/exercise/crunch"):
		$Crunches/CrunchesButton.pressed = true
	else:
		$Crunches/CrunchesButton.pressed = false

	if ProjectSettings.get("game/exercise/strength_focus"):
		$StrengthMode/StrengthModeButton.pressed = true
	else:
		$StrengthMode/StrengthModeButton.pressed = false
		
	var avg_exercise_duration = ProjectSettings.get("game/exercise_duration_avg")
	$ExerciseDuration/NumberEntry.set_value(avg_exercise_duration)

	emit_signal("content_changed")

func _ready():
	update_widgets()

func _on_HoldCueButton_pressed():
	ProjectSettings.set("game/exercise/hold_cues", $HoldCue/HoldCueButton.pressed)
	update_widgets()

func _on_ParcourButton_pressed():
	ProjectSettings.set("game/exercise/parcour", $Parcour/ParcourButton.pressed)
	update_widgets()

func _on_PushupButton_pressed():
	ProjectSettings.set("game/exercise/pushup", $Pushup/PushupButton.pressed)
	update_widgets()

func _on_SafePushupsButton_pressed():
	ProjectSettings.set("game/hud_enabled", $SafePushups/SafePushupsButton.pressed)
	update_widgets()

func _on_BurpeeButton_pressed():
	ProjectSettings.set("game/exercise/burpees", $Burpee/BurpeeButton.pressed)
	update_widgets()

func _on_StandButton_pressed():
	ProjectSettings.set("game/exercise/stand", $Stand/StandButton.pressed)
	update_widgets()

func _on_DuckingButton_pressed():
	ProjectSettings.set("game/exercise/duck", $Ducking/DuckButton.pressed)
	update_widgets()
	
func _on_WindmillButton_pressed():
	ProjectSettings.set("game/exercise/stand/windmill", $Windmill/WindmillButton.pressed)
	update_widgets()
	
func _on_EqualizerButton_pressed():
	ProjectSettings.set("game/equalizer", $Equalizer/EqualizerButton.pressed)
	update_widgets()

func _on_ExtendedTransitionButton_pressed():
	ProjectSettings.set("game/easy_transition", $ExtendedTransition/ExtendedTransitionButton.pressed)
	update_widgets()

func _on_InstructorButton_pressed():
	ProjectSettings.set("game/instructor", $Instructor/InstructorButton.pressed)
	update_widgets()
	
func _on_JumpButton_pressed():
	ProjectSettings.set("game/exercise/jump", $Jump/JumpButton.pressed)
	update_widgets()

func _onSprintButton_pressed():
	ProjectSettings.set("game/exercise/sprint", $Sprint/SprintButton.pressed)
	update_widgets()
	
func _on_SquatButton_pressed():
	ProjectSettings.set("game/exercise/squat", $Squat/SquatButton.pressed)
	update_widgets()

func _on_KneesaverButton_pressed():
	ProjectSettings.set("game/exercise/kneesaver", $Kneesaver/KneesaverButton.pressed)
	update_widgets()

func _on_CrunchesButton_pressed():
	ProjectSettings.set("game/exercise/crunch", $Crunches/CrunchesButton.pressed)
	update_widgets()

func _on_StrengthModeButton_pressed():	
	ProjectSettings.set("game/exercise/strength_focus", $StrengthMode/StrengthModeButton.pressed)
	update_widgets()
	
func _on_CurvedCuesButton_pressed():
	ProjectSettings.set("game/exercise/stand/curved", $CurvedCues/CurvedCuesButton.pressed)
	update_widgets()

func _on_ExerciseDuration_value_changed(value):
	ProjectSettings.set("game/exercise_duration_avg", value)
	update_widgets()
	
func _input(event):
	update_widgets()	
	
