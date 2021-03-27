extends Spatial

export var beast_mode = false


func update_widgets():
	if ProjectSettings.get("game/hold_cues"):
		$Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed = true
	else:
		$Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed = false
		
	if ProjectSettings.get("game/exercise/parcour"):
		$Viewport/CanvasLayer/Parcour/ParcourButton.pressed = true
	else:
		$Viewport/CanvasLayer/Parcour/ParcourButton.pressed = false

	if ProjectSettings.get("game/exercise/pushup"):
		$Viewport/CanvasLayer/Pushup/PushupButton.pressed = true
	else:
		$Viewport/CanvasLayer/Pushup/PushupButton.pressed = false

	if ProjectSettings.get("game/hud_enabled"):
		$Viewport/CanvasLayer/SafePushups/SafePushupsButton.pressed = true
	else:
		$Viewport/CanvasLayer/SafePushups/SafePushupsButton.pressed = false

	if ProjectSettings.get("game/exercise/burpees"):
		$Viewport/CanvasLayer/Burpee/BurpeeButton.pressed = true
	else:
		$Viewport/CanvasLayer/Burpee/BurpeeButton.pressed = false

	if ProjectSettings.get("game/exercise/stand"):
		$Viewport/CanvasLayer/Stand/StandButton.pressed = true
	else:
		$Viewport/CanvasLayer/Stand/StandButton.pressed = false

	if ProjectSettings.get("game/exercise/duck"):
		$Viewport/CanvasLayer/Ducking/DuckButton.pressed = true
	else:
		$Viewport/CanvasLayer/Ducking/DuckButton.pressed = false

	if ProjectSettings.get("game/exercise/stand/windmill"):
		$Viewport/CanvasLayer/Windmill/WindmillButton.pressed = true
	else:
		$Viewport/CanvasLayer/Windmill/WindmillButton.pressed = false

	if ProjectSettings.get("game/equalizer"):
		$Viewport/CanvasLayer/Equalizer/EqualizerButton.pressed = true
	else:
		$Viewport/CanvasLayer/Equalizer/EqualizerButton.pressed = false

	if ProjectSettings.get("game/easy_transition"):
		$Viewport/CanvasLayer/ExtendedTransition/ExtendedTransitionButton.pressed = true
	else:
		$Viewport/CanvasLayer/ExtendedTransition/ExtendedTransitionButton.pressed = false

	if ProjectSettings.get("game/instructor"):
		$Viewport/CanvasLayer/Instructor/InstructorButton.pressed = true
	else:
		$Viewport/CanvasLayer/Instructor/InstructorButton.pressed = false

	if ProjectSettings.get("game/exercise/jump"):
		$Viewport/CanvasLayer/Jump/JumpButton.pressed = true
	else:
		$Viewport/CanvasLayer/Jump/JumpButton.pressed = false

	if ProjectSettings.get("game/exercise/sprint"):
		$Viewport/CanvasLayer/Sprint/SprintButton.pressed = true
	else:
		$Viewport/CanvasLayer/Sprint/SprintButton.pressed = false

	if ProjectSettings.get("game/exercise/squat"):
		$Viewport/CanvasLayer/Squat/SquatButton.pressed = true
	else:
		$Viewport/CanvasLayer/Squat/SquatButton.pressed = false

	if ProjectSettings.get("game/exercise/kneesaver"):
		$Viewport/CanvasLayer/Kneesaver/KneesaverButton.pressed = true
	else:
		$Viewport/CanvasLayer/Kneesaver/KneesaverButton.pressed = false

	if ProjectSettings.get("game/exercise/crunch"):
		$Viewport/CanvasLayer/Crunches/CrunchesButton.pressed = true
	else:
		$Viewport/CanvasLayer/Crunches/CrunchesButton.pressed = false

	if ProjectSettings.get("game/beast_mode"):
		$Viewport/CanvasLayer/BeastMode/BeastModeButton.pressed = true
	else:
		$Viewport/CanvasLayer/BeastMode/BeastModeButton.pressed = false

	if ProjectSettings.get("game/exercise/strength_focus"):
		$Viewport/CanvasLayer/StrengthMode/StrengthModeButton.pressed = true
	else:
		$Viewport/CanvasLayer/StrengthMode/StrengthModeButton.pressed = false

	var yt_available = get_tree().current_scene.get_node("YoutubeInterface").is_youtube_available()
	if yt_available:
		$Viewport/CanvasLayer/Youtube.hide()
	else:
		$Viewport/CanvasLayer/Youtube.show()


	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE


var frame_limiter = 0
func _process(delta):
	frame_limiter += 1
	if frame_limiter > 50:
		frame_limiter = 0
		update_widgets()

func _ready():
	update_widgets()

func _on_HoldCueButton_pressed():
	ProjectSettings.set("game/hold_cues", $Viewport/CanvasLayer/HoldCue/HoldCueButton.pressed)
	update_widgets()


func _on_ParcourButton_pressed():
	ProjectSettings.set("game/exercise/parcour", $Viewport/CanvasLayer/Parcour/ParcourButton.pressed)
	update_widgets()


func _on_Youtube_pressed():
	var link = "%s%d"%[ProjectSettings.get("application/config/youtube_link"),OS.get_unix_time()]
	OS.shell_open(link)


func _on_PushupButton_pressed():
	ProjectSettings.set("game/exercise/pushup", $Viewport/CanvasLayer/Pushup/PushupButton.pressed)
	update_widgets()

func _on_SafePushupsButton_pressed():
	ProjectSettings.set("game/hud_enabled", $Viewport/CanvasLayer/SafePushups/SafePushupsButton.pressed)
	update_widgets()

func _on_BurpeeButton_pressed():
	ProjectSettings.set("game/exercise/burpees", $Viewport/CanvasLayer/Burpee/BurpeeButton.pressed)
	update_widgets()

func _on_StandButton_pressed():
	ProjectSettings.set("game/exercise/stand", $Viewport/CanvasLayer/Stand/StandButton.pressed)
	update_widgets()

func _on_DuckingButton_pressed():
	ProjectSettings.set("game/exercise/duck", $Viewport/CanvasLayer/Ducking/DuckButton.pressed)
	update_widgets()
	
func _on_WindmillButton_pressed():
	ProjectSettings.set("game/exercise/stand/windmill", $Viewport/CanvasLayer/Windmill/WindmillButton.pressed)
	update_widgets()
	
func _on_EqualizerButton_pressed():
	ProjectSettings.set("game/equalizer", $Viewport/CanvasLayer/Equalizer/EqualizerButton.pressed)
	update_widgets()

func _on_ExtendedTransitionButton_pressed():
	ProjectSettings.set("game/easy_transition", $Viewport/CanvasLayer/ExtendedTransition/ExtendedTransitionButton.pressed)
	update_widgets()

func _on_InstructorButton_pressed():
	ProjectSettings.set("game/instructor", $Viewport/CanvasLayer/Instructor/InstructorButton.pressed)
	update_widgets()
	
func _on_JumpButton_pressed():
	ProjectSettings.set("game/exercise/jump", $Viewport/CanvasLayer/Jump/JumpButton.pressed)
	update_widgets()

func _onSprintButton_pressed():
	ProjectSettings.set("game/exercise/sprint", $Viewport/CanvasLayer/Sprint/SprintButton.pressed)
	update_widgets()
	
func _on_SquatButton_pressed():
	ProjectSettings.set("game/exercise/squat", $Viewport/CanvasLayer/Squat/SquatButton.pressed)
	update_widgets()

func _on_KneesaverButton_pressed():
	ProjectSettings.set("game/exercise/kneesaver", $Viewport/CanvasLayer/Kneesaver/KneesaverButton.pressed)
	update_widgets()

func _on_CrunchesButton_pressed():
	ProjectSettings.set("game/exercise/crunch", $Viewport/CanvasLayer/Crunches/CrunchesButton.pressed)
	update_widgets()

func _on_BeastModeButton_pressed():
	beast_mode = not beast_mode
	get_tree().current_scene.set_beast_mode(beast_mode)

	ProjectSettings.set("game/beast_mode", $Viewport/CanvasLayer/BeastMode/BeastModeButton.pressed)
	update_widgets()

func _on_StrengthModeButton_pressed():	
	ProjectSettings.set("game/exercise/strength_focus", $Viewport/CanvasLayer/StrengthMode/StrengthModeButton.pressed)
	update_widgets()


	
#	get_node("SettingsCarousel/Switchboard/YogaSwitch").value = ProjectSettings.get("game/exercise/yoga")
#	get_node("SettingsCarousel/Switchboard/YogaSwitch").update_switch()

	




