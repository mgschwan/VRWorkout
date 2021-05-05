extends Spatial


var player_model = preload("res://scenes/RemoteAvatar.tscn")
var controller_model = preload("res://scenes/RemoteHands.tscn")

var player_containers = Dictionary()
var player_objects = Dictionary()
var additional_objects = Dictionary()

func _on_MultiplayerRoom_add_spatial(userid, nodeid, type,parent_node):
	print ("Add spatial: %s %s %s (parent: %s)"%[userid, nodeid, type,str(parent_node)])
	var container = player_containers.get(userid, null)
	if not player_containers.has(userid):
		container = Spatial.new()
		add_child(container)
		player_containers[userid] = container
	
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
		container.add_child(node)
	elif type == "controller":
		node = controller_model.instance()
		node.translation.x = 0
		node.translation.z = 0
		node.multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
		node.remote_player_id = userid
		node.remote_node_id = nodeid
		node.is_local = false

		container.add_child(node)
		if not (userid in additional_objects):
			additional_objects[userid] = Dictionary()
		additional_objects[userid][nodeid] = node
	else:
			print ("don't add spatial")

func remove_all_entities():
	for c in get_children():
		c.queue_free()
	player_objects = Dictionary()
	additional_objects = Dictionary()
	player_containers = Dictionary()

func _on_MultiplayerRoom_user_leave(userid):
	print ("Remove user")
	var p = player_containers.get(userid,null)
	if p:
		p.queue_free()
	player_containers.erase(userid)
	additional_objects.erase(userid)
	player_objects.erase(userid)

func _on_MultiplayerRoom_remove_spatial(userid, nodeid):
	print ("Remove spatial")
	if userid in additional_objects:
		if nodeid in additional_objects[userid]:
			if additional_objects[userid][nodeid] == null:
				#That should not happen but it does
				pass
			else:
				additional_objects[userid][nodeid].queue_free()
			additional_objects.erase(nodeid)
