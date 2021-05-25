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

	multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
	
	if not ProjectSettings.get("game/portal_connection") or not GameVariables.FEATURE_MULTIPLAYER:
		$ConnectPad.hide()
		$MPInfo.show()
	else:
		$ConnectPad.show()
		$MPInfo.hide()


var frame_count = 0
func _process(delta):
	if GameVariables.FEATURE_MULTIPLAYER:
		if frame_count == 0:
			if ProjectSettings.get("game/portal_connection") != $ConnectPad.visible:
				if $ConnectPad.visible:
					$ConnectPad.hide()
					$MPInfo.show()
				else:
					$ConnectPad.show()
					$MPInfo.hide()
				emit_signal("content_changed")
			elif GameVariables.multiplayer_api and GameVariables.multiplayer_api.is_multiplayer():
				if GameVariables.multiplayer_api.room != get_node("ConnectPad/Code").text :
					get_node("ConnectPad/Code").text = GameVariables.multiplayer_api.room
					emit_signal("content_changed")
					
		frame_count = (frame_count + 1)%20

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
	 
