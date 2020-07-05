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
	get_node("SettingsCarousel/BeastModeSelector").beast_mode = ProjectSettings.get("game/beast_mode")
	get_node("SettingsCarousel/BeastModeSelector").update_switch()
	
	get_node("SettingsCarousel/JumpSwitch").value = ProjectSettings.get("game/exercise/jump")
	get_node("SettingsCarousel/JumpSwitch").update_switch()
	
	get_node("SettingsCarousel/StandSwitch").value = ProjectSettings.get("game/exercise/stand")
	get_node("SettingsCarousel/StandSwitch").update_switch()
	
	get_node("SettingsCarousel/SquatSwitch").value = ProjectSettings.get("game/exercise/squat")
	get_node("SettingsCarousel/SquatSwitch").update_switch()
	
	get_node("SettingsCarousel/PushupSwitch").value = ProjectSettings.get("game/exercise/pushup")
	get_node("SettingsCarousel/PushupSwitch").update_switch()
	
	get_node("SettingsCarousel/SafePushupSwitch").value = ProjectSettings.get("game/hud_enabled")
	get_node("SettingsCarousel/SafePushupSwitch").update_switch()

	get_node("SettingsCarousel/CrunchSwitch").value = ProjectSettings.get("game/exercise/crunch")
	get_node("SettingsCarousel/CrunchSwitch").update_switch()

	get_node("SettingsCarousel/BurpeeSwitch").value = ProjectSettings.get("game/exercise/burpees")
	get_node("SettingsCarousel/BurpeeSwitch").update_switch()

	get_node("SettingsCarousel/DuckSwitch").value = ProjectSettings.get("game/exercise/duck")
	get_node("SettingsCarousel/DuckSwitch").update_switch()

	get_node("SettingsCarousel/YogaSwitch").value = ProjectSettings.get("game/exercise/yoga")
	get_node("SettingsCarousel/YogaSwitch").update_switch()

	get_node("SettingsCarousel/SprintSwitch").value = ProjectSettings.get("game/exercise/sprint")
	get_node("SettingsCarousel/SprintSwitch").update_switch()

	get_node("SettingsCarousel/KneesaverSwitch").value = ProjectSettings.get("game/exercise/kneesaver")
	get_node("SettingsCarousel/KneesaverSwitch").update_switch()

	
	
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


func _on_SongSelector_level_selected(filename, difficulty, level_number):
	emit_signal("level_selected", filename, difficulty, level_number)

func _on_YogaSwitch_toggled(value):
	ProjectSettings.set("game/exercise/yoga", value)


func _on_ExerciseCollection_selected(collection):
	gu.set_exercise_collection(collection)
	update_widget()


func _on_SettingsButton_selected():
	var carousel = get_node("SettingsCarousel")
	var t = get_node("SettingsCarousel/Tween")
	t.interpolate_property(carousel, "rotation:y", carousel.rotation.y, 0, 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	t.start()
	
func _on_ExerciseButton_selected():
	var carousel = get_node("SettingsCarousel")
	var t = get_node("SettingsCarousel/Tween")
	t.interpolate_property(carousel, "rotation:y", carousel.rotation.y, PI, 0.5, 	Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	t.start()

