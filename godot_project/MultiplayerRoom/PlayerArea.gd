extends Spatial


var player_model = preload("res://scenes/RemoteAvatar.tscn")
var controller_model = preload("res://scenes/RemoteHands.tscn")

var player_objects = {}
var additional_objects = {}

func _on_MultiplayerRoom_add_spatial(userid, nodeid, type,parent_node):
	print ("Add spatial: %s %s %s"%[userid, nodeid, type])
	var node = null
	if type == "player":
		node = player_model.instance()
		node.translation.x = 0
		node.translation.z = 0
		node.multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
		node.remote_player_id = userid
		node.remote_node_id = nodeid
		node.is_local = false
		player_objects[userid] = node
		add_child(node)
	elif type == "controller":
		node = controller_model.instance()
		node.translation.x = 0
		node.translation.z = 0
		node.multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
		node.remote_player_id = userid
		node.remote_node_id = nodeid
		node.is_local = false
		#TODO ensure that the player object has already been created before adding controllers
		if parent_node >= 0:
			var p = player_objects.get(userid,null)
			if p:
				p.add_child(node)
		else:
			additional_objects[nodeid] = node
			add_child(node)

func _on_MultiplayerRoom_user_leave(userid):
	print ("Remove user")
	var p = player_objects.get(userid,null)
	if p:
		p.queue_free()

func _on_MultiplayerRoom_remove_spatial(userid, nodeid):
	print ("Remove spatial")
	if nodeid in additional_objects:
		if additional_objects[nodeid]:
			additional_objects[nodeid].queue_free()
