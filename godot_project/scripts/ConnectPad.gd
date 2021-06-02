extends Control

signal content_changed()

var is_pressed = false
var last_position = Vector2(0,0)

var multiplayer_room = null

func _ready():
	if len(OS.get_cmdline_args()) > 0:
		var arg = OS.get_cmdline_args()[0]
		if arg.find("room:") >= 0:
			get_node("ConnectPad/Code").text = arg.split(":")[1]

	$ConnectPad/PlayerName.text = GameVariables.player_name

	multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
	
	if not ProjectSettings.get("game/portal_connection") or not GameVariables.FEATURE_MULTIPLAYER:
		$ConnectPad.hide()
		$MPInfo.show()
	else:
		$ConnectPad.show()
		$MPInfo.hide()


var frame_count = 0
var slow_frame_count = 0
func _process(delta):
	var data_updated = false
	if GameVariables.FEATURE_MULTIPLAYER:
		if frame_count == 0:
			if ProjectSettings.get("game/portal_connection") != $ConnectPad.visible:
				if $ConnectPad.visible:
					$ConnectPad.hide()
					$MPInfo.show()
				else:
					$ConnectPad.show()
					$MPInfo.hide()
				data_updated = true
			elif GameVariables.multiplayer_api and GameVariables.multiplayer_api.is_multiplayer():
				if $ConnectPad/CreateRoom.visible or $"ConnectPad/Enter Room".visible or $ConnectPad/Clear.visible:
					$ConnectPad/CreateRoom.hide()
					$"ConnectPad/Enter Room".hide()
					$ConnectPad/Clear.hide()
					$ConnectPad/ExitRoom.show()
					data_updated = true
				
				if GameVariables.multiplayer_api.room != get_node("ConnectPad/Code").text :
					get_node("ConnectPad/Code").text = GameVariables.multiplayer_api.room
					data_updated = true
			elif GameVariables.multiplayer_api and not GameVariables.multiplayer_api.is_multiplayer():
				if $ConnectPad/ExitRoom.visible:
					$ConnectPad/CreateRoom.show()
					$"ConnectPad/Enter Room".show()
					$ConnectPad/Clear.show()
					$ConnectPad/ExitRoom.hide()
					data_updated = true

		if slow_frame_count == 0 and GameVariables.multiplayer_api:
			update_player_list()		
			data_updated = true
			
				
		frame_count = (frame_count + 1)%20
		slow_frame_count = (slow_frame_count + 1)%100
	if data_updated:
		emit_signal("content_changed")
		
func update_player_list():
	var scores = GameVariables.multiplayer_api.get_scores()
	$ConnectPad/PlayerList.clear()
	$ConnectPad/PlayerList.add_item("%s - %.1f"%[GameVariables.player_name, GameVariables.game_result.get("points",0.0)])
	for u in scores:
		var name = GameVariables.multiplayer_api.get_player_name(u)
		var points = scores[u]["points"]
		$ConnectPad/PlayerList.add_item("%s - %.1f"%[name, points])

func _on_Button_button_down(character):
	get_node("ConnectPad/Code").text += character

func _on_Clear_button_down():
	get_node("ConnectPad/Code").text = ""

func _on_CreateRoom_button_down():
	if multiplayer_room:
		multiplayer_room.connect_to_server(GameVariables.multiplayer_server, "")
	
func _on_ExitRoom_button_down():
	if multiplayer_room:
		multiplayer_room.disconnect_from_server()

func _on_Enter_Room_pressed():
	#TODO: check if it's already connected and handle accordingly
	if multiplayer_room:
		multiplayer_room.connect_to_server(GameVariables.multiplayer_server, get_node("ConnectPad/Code").text)

func _on_PlayerName_gui_input(event):
	if event is InputEventMouseButton:
		if event.pressed and (GameVariables.multiplayer_api and not GameVariables.multiplayer_api.is_multiplayer()): 
			get_tree().current_scene.attach_keyboard($ConnectPad/PlayerName)


func _on_PlayerName_text_entered(new_text):
	var name = $ConnectPad/PlayerName.text
	GameVariables.player_name = name	
	emit_signal("content_changed")
