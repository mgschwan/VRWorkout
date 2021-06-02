extends Spatial

signal level_selected(filename, difficulty, level_number)
signal onboarding_selected()

var gu = GameUtilities.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

	
func update_widget():
	get_node("SettingsCarousel/Connections/VRWorkoutConnection/PortalInfo").set_state(ProjectSettings.get("game/portal_connection"))

	get_node("BPM/OverrideBeats").value = ProjectSettings.get("game/override_beats")
	get_node("BPM/OverrideBeats").update_switch()

	GameVariables.exercise_state_list = []
	
	
	
# Called when the node enters the scene tree for the first time.
func _ready():
	var environment = ProjectSettings.get("game/environment")
	if environment:
		get_tree().current_scene.change_environment(environment)
	show_settings("empty")
	
	get_node("SongSelector").set_songs(get_tree().current_scene.get_node("SongDatabase").song_list())
	if GameVariables.current_song:
		get_node("SongSelector").playlist_from_song_files(GameVariables.current_song)
	
	#get_node("MainText").print_info("[img]res://assets/vrworkout_logo.png[/img]\nBuild a playlist with the songs to your right and press start.\n[center][b]Tips[/b][/center]\n- Play with hand tracking (no controllers)\n- Connect a heart rate sensor for dynamic difficulty\n- Support is at [b]https://chat.vrworkout.at[/b]\n- Early access! Please judge mechanics not graphics")
	
	update_widget()
	get_node("SongSelector").select_difficulty(GameVariables.difficulty)
	GameVariables.vr_camera.blackout_screen(false)
	#show_settings("battle")
	yield(get_tree().create_timer(1.0),"timeout")
	show_settings("exercises")
	
	print ("GET ROOM SERVER")
	var value_container = Dictionary()
	var co = get_tree().current_scene.get_node("RemoteInterface").generic_get_request("/room_server/%s/"%GameVariables.device_id, value_container)
	if co is GDScriptFunctionState && co.is_valid():
		#print ("Achievement yield until panel finished")
		yield(co, "completed")
	var result = value_container.get("result",{})
	print ("Room server result: %s"%str(result))
	GameVariables.multiplayer_server = result.get("server", GameVariables.multiplayer_server)
	print ("Room Server: %s"%str(GameVariables.multiplayer_server))

	update_multiplayer_panels()
	
	GameVariables.vr_camera.blackout_screen(false)



func set_main_text(text):
	pass
	#get_node("MainText").print_info(text)

func set_stat_text(text, score):
	pass
	#get_node("Stats").print_info(text)
	#get_node("Stats/gauge").set_value(score)
	#get_node("Stats/gauge").show()

func get_last_beat():
	return get_node("BPM").last_beat

func _on_multiplayer_room_joined(as_host):
	update_multiplayer_panels()
		
func _on_multiplayer_room_left():
	update_multiplayer_panels()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
var controller_detail_set = false
func _process(delta):
	if not controller_detail_set:
		print ("Set small controller")
		get_tree().current_scene.set_detail_selection_mode(true)
		controller_detail_set = true
	

func _on_OverrideBeats_toggled(value):
	ProjectSettings.set("game/override_beats", value)

func _on_SongSelector_level_selected(filename, difficulty, level_number):
	emit_signal("level_selected", filename, difficulty, level_number)

func _on_YogaSwitch_toggled(value):
	ProjectSettings.set("game/exercise/yoga", value)


func _on_ExerciseCollection_selected(collection):
	GameVariables.game_mode = GameVariables.GameMode.EXERCISE_SET
	GameVariables.achievement_checks = Array()
	gu.set_exercise_collection(collection)
	update_widget()

func show_settings(panel):
	var connections_node = get_node("SettingsCarousel/Connections")
	var exercises_node = get_node("SettingsCarousel/Exercises")
	var battle_node = get_node("SettingsCarousel/Battle")
	var carousel = get_node("SettingsCarousel")
	var t = get_node("SettingsCarousel/Tween")

	var angle = 0

	carousel.translation.y = -3

	if panel == "connections":
		gu.activate_node(connections_node)
		gu.deactivate_node(exercises_node)
		gu.deactivate_node(battle_node)
		angle = 3*PI/2.0
	elif panel == "exercises":
		gu.deactivate_node(connections_node)
		gu.activate_node(exercises_node)
		gu.deactivate_node(battle_node)
		angle = PI
	elif panel == "battle":
		gu.deactivate_node(connections_node)
		gu.deactivate_node(exercises_node)
		gu.activate_node(battle_node)

		angle = PI/2.0
	elif panel == "empty":
		gu.deactivate_node(connections_node)
		gu.deactivate_node(exercises_node)
		gu.deactivate_node(battle_node)
		angle = PI/2.0
		return

	t.interpolate_property(carousel, "rotation:y", carousel.rotation.y, angle, 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	t.interpolate_property(carousel, "translation:y", -3, 0, 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	t.interpolate_property(carousel, "scale", Vector3(0,0,0), Vector3(1,1,1) , 0.5, Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)

	t.start()

		
	
func _on_ExerciseButton_selected():
	show_settings("exercises")	

func _on_ConnectionsButton_selected():
	show_settings("connections")	

func _on_BattleButton_selected():
	show_settings("battle")	


func _on_PresetCollector_selected(collection, achievements):
	GameVariables.game_mode = GameVariables.GameMode.STANDARD
	GameVariables.exercise_state_list = collection
	GameVariables.achievement_checks = achievements
	
func _on_PortalSwitch_toggled(value):
	ProjectSettings.set("game/portal_connection", value)

func _on_Recenter_selected():
	get_tree().current_scene.start_countdown(5,"recenter_screen")

func _on_StoredSlot_selected(exercise_list, slot_number, level_statistics_data):
	if len(exercise_list) > 0:
		GameVariables.game_mode = GameVariables.GameMode.STORED
		GameVariables.selected_game_slot = slot_number
		GameVariables.cue_list = exercise_list.duplicate()
		GameVariables.input_level_statistics_data = level_statistics_data
	else:
		GameVariables.game_mode = GameVariables.GameMode.STANDARD
	GameVariables.achievement_checks = Array()

var challenge_upload_possible = true
func _on_CreateChallengeButton_selected():
	#DISABLED on 04/13/21 until challenge upload is properly integrated into the new menu
	#TODO	
	pass
#	if challenge_upload_possible:
#		challenge_upload_possible = false
#		gu.upload_challenge(get_tree().current_scene.get_node("RemoteInterface"))
#		#Prevent double uploads from spurious button events
#		yield(get_tree().create_timer(2.0),"timeout")
#	challenge_upload_possible = true

func update_battle_mode():
	if GameVariables.battle_mode == GameVariables.BattleMode.NO:
		get_node("SettingsCarousel/Battle/Opponents/NoEnemy").mark_active()
	else:
		if GameVariables.battle_enemy == "easy":
			get_node("SettingsCarousel/Battle/Opponents/EasyEnemy").mark_active()
		elif GameVariables.battle_enemy == "medium":
			get_node("SettingsCarousel/Battle/Opponents/MediumEnemy").mark_active()
		elif GameVariables.battle_enemy == "hard":
			get_node("SettingsCarousel/Battle/Opponents/HardEnemy").mark_active()


func _on_BattleMode_selected(team, enemy):
	if team == "red":
		GameVariables.battle_team = GameVariables.BattleTeam.RED
	else:	
		GameVariables.battle_team = GameVariables.BattleTeam.BLUE
	
	if enemy == "none":
		GameVariables.battle_enemy = enemy	
		GameVariables.battle_mode = GameVariables.BattleMode.NO
	else:
		GameVariables.battle_enemy = enemy	
		GameVariables.battle_mode = GameVariables.BattleMode.CPU
	update_battle_mode()




func _on_TrackerRecorderButton_selected():
	ProjectSettings.set("game/record_tracker",true)


func _on_AudioStreamPlayer_finished():
	get_node("AudioStreamPlayer").play(0)




func _on_GamePanel_onboarding_selected():
	print ("Levelselect onboarding selected")
	emit_signal("onboarding_selected")

func update_multiplayer_panels():
	if GameVariables.multiplayer_api and GameVariables.multiplayer_api.is_multiplayer_client():
		$SongSelector.hide_panels()
	else:
		$SongSelector.show_panels()
		
func _on_multiplayer_game_message(sender, message):
	var message_type = message.get("type","")
	if message_type == "playlist":
		var playlist = message.get("playlist","")		
		print ("Playlist received: %s"%str(playlist))
		$SongSelector.set_playlist(playlist)
	elif message_type == "start":
		var exercise_list = message.get("exercise_list",[])
		_on_StoredSlot_selected(exercise_list, -1, [])
		emit_signal("level_selected", $SongSelector.playlist, 0, 0)
