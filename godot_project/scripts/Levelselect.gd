extends Spatial

signal level_selected(filename, difficulty, level_number)

var gu = GameUtilities.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_song_list(path):
	var song_dict = {}
	var dir = Directory.new()
	var ec = dir.open(path)
	
	if ec == OK:
		dir.list_dir_begin()
		var fname = dir.get_next()
		while fname != "":
			if not dir.current_is_dir():
				var fields = fname.split(".")
				print (str(fields))
				if fields and (fields[-1] == "ogg" or fields[-1] == "import"):
					var tmpf = fname
					if fields[-1] == "import":
						tmpf = fname.rsplit(".",true,1)[0]
					var full_path = "%s/%s"%[dir.get_current_dir(),tmpf]
					song_dict[full_path] = 1
			fname = dir.get_next()
	
	return song_dict.keys()
	

	
func update_widget():
	get_node("SettingsCarousel/Switchboard/BeastModeSelector").beast_mode = ProjectSettings.get("game/beast_mode")
	get_node("SettingsCarousel/Switchboard/BeastModeSelector").update_switch()
	
	get_node("SettingsCarousel/Switchboard/JumpSwitch").value = ProjectSettings.get("game/exercise/jump")
	get_node("SettingsCarousel/Switchboard/JumpSwitch").update_switch()
	
	get_node("SettingsCarousel/Switchboard/StandSwitch").value = ProjectSettings.get("game/exercise/stand")
	get_node("SettingsCarousel/Switchboard/StandSwitch").update_switch()
	
	get_node("SettingsCarousel/Switchboard/SquatSwitch").value = ProjectSettings.get("game/exercise/squat")
	get_node("SettingsCarousel/Switchboard/SquatSwitch").update_switch()
	
	get_node("SettingsCarousel/Switchboard/PushupSwitch").value = ProjectSettings.get("game/exercise/pushup")
	get_node("SettingsCarousel/Switchboard/PushupSwitch").update_switch()
	
	get_node("SettingsCarousel/Switchboard/SafePushupSwitch").value = ProjectSettings.get("game/hud_enabled")
	get_node("SettingsCarousel/Switchboard/SafePushupSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/CrunchSwitch").value = ProjectSettings.get("game/exercise/crunch")
	get_node("SettingsCarousel/Switchboard/CrunchSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/BurpeeSwitch").value = ProjectSettings.get("game/exercise/burpees")
	get_node("SettingsCarousel/Switchboard/BurpeeSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/DuckSwitch").value = ProjectSettings.get("game/exercise/duck")
	get_node("SettingsCarousel/Switchboard/DuckSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/YogaSwitch").value = ProjectSettings.get("game/exercise/yoga")
	get_node("SettingsCarousel/Switchboard/YogaSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/SprintSwitch").value = ProjectSettings.get("game/exercise/sprint")
	get_node("SettingsCarousel/Switchboard/SprintSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/EqualizerSwitch").value = ProjectSettings.get("game/equalizer")
	get_node("SettingsCarousel/Switchboard/EqualizerSwitch").update_switch()


	get_node("SettingsCarousel/Switchboard/KneesaverSwitch").value = ProjectSettings.get("game/exercise/kneesaver")
	get_node("SettingsCarousel/Switchboard/KneesaverSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/StrengthCardioSwitch").value = ProjectSettings.get("game/exercise/strength_focus")
	get_node("SettingsCarousel/Switchboard/StrengthCardioSwitch").update_switch()

	get_node("SettingsCarousel/Connections/VRWorkoutConnection/PortalSwitch").value = ProjectSettings.get("game/portal_connection")
	get_node("SettingsCarousel/Connections/VRWorkoutConnection/PortalSwitch").update_switch()

	get_node("SettingsCarousel/Switchboard/InstructorSwitch").value = ProjectSettings.get("game/instructor")
	get_node("SettingsCarousel/Switchboard/InstructorSwitch").update_switch()



	GameVariables.exercise_state_list = []
	get_node("SettingsCarousel/Exercises/StandardWorkout").mark_active()
	show_settings("exercises")
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var songs = []
#			 ["res://audio/songs/vrworkout.ogg",
#			"res://audio/songs/cdk_deeper_in_yourself.ogg",
#			"res://audio/songs/cdk_like_this.ogg",
#			"res://audio/songs/cdk_the_game_has_changed.ogg",
#			"res://audio/songs/ffact_shameless_site_promotion.ogg",
#			"res://audio/songs/scomber_clarity.ogg",
#			"res://audio/songs/vrworkout_beater.ogg",
#			"res://audio/nonfree_songs/Slayers_of_the_Ice_Dragon.ogg",
#			"res://audio/nonfree_songs/Duty_to_Humanity.ogg"]
	
	songs += get_song_list("res://audio/songs")
	songs += get_song_list("res://audio/nonfree_songs")
	var external_dir = ProjectSettings.get("game/external_songs")

	if external_dir:
		songs += get_song_list(external_dir)	

	print (str(songs))
	get_node("SongSelector").set_songs(songs)
	
	get_node("MainText").print_info("VRWorkout\nSelect song by touching a block\nBest played hands only - no controllers\nPosition yourself between the blue poles\nRun in place to get multipliers\n\nTurn around for a tutorial")
	
	get_node("Tutorial").print_info("How to play\n- Hit the hand cues to the beat of the music\n- Head cues should only be touched no headbutts\n- Run in place to receive point multipliers!\nThe optimal time to hit the cues is when the\nrotating marker meets the static one")	
	
	update_widget()
	get_node("SongSelector").select_difficulty(GameVariables.difficulty)
	get_viewport().get_camera().blackout_screen(false)


func set_main_text(text):
	get_node("MainText").print_info(text)

func set_stat_text(text, score):
	get_node("Stats").print_info(text)
	get_node("Stats/gauge").set_value(score)
	get_node("Stats/gauge").show()

func get_last_beat():
	return get_node("BPM").last_beat



# Called every frame. 'delta' is the elapsed time since the previous frame.
var controller_detail_set = false
func _process(delta):
	if not controller_detail_set:
		print ("Set small controller")
		get_tree().current_scene.set_detail_selection_mode(true)
		controller_detail_set = true


func _on_JumpSwitch_toggled(value):
	ProjectSettings.set("game/exercise/jump", value)
	
func _on_StandSwitch_toggled(value):
	ProjectSettings.set("game/exercise/stand", value)


func _on_CrunchSwitch_toggled(value):
	ProjectSettings.set("game/exercise/crunch", value)


func _on_SquatSwitch_toggled(value):
	ProjectSettings.set("game/exercise/squat", value)


func _on_PushupSwitch_toggled(value):
	ProjectSettings.set("game/exercise/pushup", value)


func _on_BurpeeSwitch_toggled(value):
	ProjectSettings.set("game/exercise/burpees", value)


func _on_DuckSwitch_toggled(value):
	ProjectSettings.set("game/exercise/duck", value)


func _on_SprintSwitch_toggled(value):
	ProjectSettings.set("game/exercise/sprint", value)

func _on_KneesaverSwitch_toggled(value):
	ProjectSettings.set("game/exercise/kneesaver", value)

func _on_SafePushupSwitch_toggled(value):
	ProjectSettings.set("game/hud_enabled", value)

func _on_StrengthCardioSwitch_toggled(value):
	ProjectSettings.set("game/exercise/strength_focus", value)

func _on_EqualizerSwitch_toggled(value):
	ProjectSettings.set("game/equalizer", value)


func _on_SongSelector_level_selected(filename, difficulty, level_number):
	emit_signal("level_selected", filename, difficulty, level_number)

func _on_YogaSwitch_toggled(value):
	ProjectSettings.set("game/exercise/yoga", value)


func _on_ExerciseCollection_selected(collection):
	gu.set_exercise_collection(collection)
	update_widget()


func show_settings(panel):
	var switchboard_node = get_node("SettingsCarousel/Switchboard")
	var connections_node = get_node("SettingsCarousel/Connections")
	var exercises_node = get_node("SettingsCarousel/Exercises")
	var carousel = get_node("SettingsCarousel")
	var t = get_node("SettingsCarousel/Tween")

	var angle = 0

	if panel == "switchboard":
		gu.activate_node(switchboard_node)
		gu.deactivate_node(connections_node)
		gu.deactivate_node(exercises_node)
		angle = 0
	elif panel == "connections":
		gu.deactivate_node(switchboard_node)
		gu.activate_node(connections_node)
		gu.deactivate_node(exercises_node)
		angle = 3*PI/2.0
	elif panel == "exercises":
		gu.deactivate_node(switchboard_node)
		gu.deactivate_node(connections_node)
		gu.activate_node(exercises_node)
		angle = PI
	elif panel == "empty":
		gu.deactivate_node(switchboard_node)
		gu.deactivate_node(connections_node)
		gu.deactivate_node(exercises_node)
		angle = PI/2.0

	t.interpolate_property(carousel, "rotation:y", carousel.rotation.y, angle, 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	t.start()
		
func _on_SettingsButton_selected():
	show_settings("switchboard")	
	
func _on_ExerciseButton_selected():
	show_settings("exercises")	

func _on_ConnectionsButton_selected():
	show_settings("connections")	

func _on_PresetCollector_selected(collection):
	GameVariables.exercise_state_list = collection

func _on_PortalSwitch_toggled(value):
	ProjectSettings.set("game/portal_connection", value)

func _on_InstructorSwitch_toggled(value):
	ProjectSettings.set("game/instructor", value)


func _on_Recenter_selected():
	get_tree().current_scene.start_countdown(5,"recenter_screen")
