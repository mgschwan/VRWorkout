extends Spatial


var player_model = preload("res://scenes/RemoteAvatar.tscn")
var controller_model = preload("res://scenes/RemoteHands.tscn")
var player_info = preload("res://scenes/PlayerInfo.tscn")

var player_containers = Dictionary()
var player_objects = Dictionary()
var additional_objects = Dictionary()
var player_scores = Dictionary()


func _on_MultiplayerRoom_add_spatial(userid, nodeid, type,parent_node):
	print ("Add spatial: %s %s %s (parent: %s)"%[userid, nodeid, type,str(parent_node)])
	var container = player_containers.get(userid, null)
	if not player_containers.has(userid):
		container = Spatial.new()
		add_child(container)
		player_containers[userid] = container
		player_scores[userid] = {"points": 0}
	
	var node = null
	if type == "player":
		node = player_model.instance()
		node.name = "Player"
		node.translation.x = 0
		node.translation.z = 0
		node.multiplayer_room = get_tree().current_scene.get_node("MultiplayerRoom")
		node.remote_player_id = userid
		node.remote_node_id = nodeid
		node.is_local = false
		player_objects[userid] = node
		container.add_child(node)
		var pinfo = player_info.instance()
		pinfo.name = "PlayerInfo"
		node.add_child(pinfo)
		pinfo.set_player_name(GameVariables.multiplayer_api.get_player_name(userid))
		pinfo.translation.y = 1.2

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
	player_scores = Dictionary()

func _on_MultiplayerRoom_user_leave(userid):
	print ("Remove user")
	var p = player_containers.get(userid,null)
	if p:
		p.queue_free()
	player_containers.erase(userid)
	additional_objects.erase(userid)
	player_objects.erase(userid)
	player_scores.erase(userid)

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


func _on_update_user_points(userid, points, rank):
	print ("Set points: %d  %d"%[userid, points])
	var container = player_containers.get(userid, null)
	if container:
		if container.has_node("Player/PlayerInfo"):
			var info = container.get_node("Player/PlayerInfo")
			info.set_points(points)
			info.set_rank(rank)
	if not userid in player_scores:
		player_scores[userid] = Dictionary()
	player_scores[userid]["points"] = points
		


