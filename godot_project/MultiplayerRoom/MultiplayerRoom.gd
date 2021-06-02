extends Node

signal user_join(id, name)
signal user_leave(id)
signal add_spatial(userid, nodeid, type, parent_node)
signal remove_spatial(userid, nodeid)
signal connected()
signal room_joined(as_host)
signal room_left()
signal game_message(userid, data)
signal spatial_offset_message(transform)


var is_active = false
var is_host = false

var self_id = -1
var user_list = {}

var room = ""

var client = WebSocketClient.new()

var conn_peer

#This id is our own id
func is_self_user(id):
	return id == self_id
	
func is_multiplayer_host():
	return is_active and is_host
	
func is_multiplayer_client():
	return is_active and (!is_host)

func is_multiplayer():
	return is_active

func remove_user(id):
	if id in user_list:
		var nodes = user_list[id].get("nodes",{})
		for n in nodes.keys():
			emit_signal("remove_spatial",id,n) 
	user_list.erase(id)
	
func update_users(ulist):
	var pre_update_users = {}
	for u in user_list.keys():
		pre_update_users[u] = 1
	
	for user in ulist:
		var id = user[0]
		var name = user[1]
		var new_user = true
		if id in user_list:
			new_user = false
			pre_update_users.erase(id)
		if new_user and id != self_id:
			user_list[id] = {"name":name, "nodes": {}}
			emit_signal("user_join", id, name)

	print ("The following users left: %s"%str(pre_update_users))
	
	for u in pre_update_users:
		remove_user(u)
		emit_signal("user_leave", u)
		
func get_node_position(id, target_node):
	var user = user_list.get(id,{})
	var nodes = user.get("nodes",{})
	#print ("Get node position: <%s> <%s> %s"%[str(id), str(target_node), str(user)])
	var node_position = nodes.get(target_node,{"pos":Vector3(0,0,0), "rot":Vector3(0,0,0)})
	return node_position	

func spatial_remove_message(node):
	var pos_update = {"nodeid":node.get_instance_id()}
	self.send_message("spatial_remove", pos_update)


var update_limiter = 0
var network_rot_offset = Quat.IDENTITY
var network_pos_offset = Vector3(0,0,0)

func send_move_message(node, parent, node_type, movement_vector):
	var pos_net = network_pos_offset + network_rot_offset.xform( node.translation ) 
	
#	update_limiter += 1
#	if update_limiter > 20:
#		print ("Move message: pre %s  post %s"%[str(node.translation),str(pos_net)])
#		update_limiter = 0
		
	var move_net = network_rot_offset.xform(movement_vector)
	var pos_rot = (node.transform.basis * Transform(network_rot_offset).basis).get_euler()
	#Transform
	var pos_update = {"nodeid":node.get_instance_id(),"parent": parent,
													  "type" : node_type,
													  "pos": [pos_net.x,
														  pos_net.y,
														  pos_net.z],
												      "rot": [pos_rot.x,
														  pos_rot.y,
														  pos_rot.z],
													  "movement": [move_net.x,
														   move_net.y,
														move_net.z]}
	self.send_message("move", pos_update)

func process_spatial_remove_message(data_object):
	#TODO: Why did I prevent the multiplayer host from removing
	#elements? Check if it works without it and the remove that check
	#if not is_multiplayer_host():
	var data = data_object.get("data", {})
	var id = data_object.get("id",-1)
	var target_node = data.get("nodeid","root")
	var user = user_list.get(id,null)
	if user and id != self_id:
		if "nodes" in user:
			if target_node in user["nodes"]:
				user["nodes"].erase(target_node)
				emit_signal("remove_spatial",id,target_node) 


#Game Messages are passed through by the server without evaluating them
#The are meant to transport game specific messages
func process_game_message(data_object):
	var data = data_object.get("data", {})
	var id = data_object.get("id",-1)
	#print ("Game Message received %s"%str(data))
	emit_signal("game_message", id, data)

func send_game_message(message):
	#print ("Send game message: %s"%str(message))
	self.send_message("game_message", message)

func process_move_message(data_object):
	var data = data_object.get("data", {})
	var id = data_object.get("id",-1)
	var target_node = data.get("nodeid","root")
	var parent_node = data.get("parent",-1)
	var node_type = data.get("type","player")
	var pos = data.get("pos", Vector3(0,0,0))
	var rot = data.get("rot", Vector3(0,0,0))
	var movement = data.get("movement", Vector3(0,0,0))
	#print ("Move message: %s"%str(data))
	var user = user_list.get(id,null)
	if user and id != self_id:
		if GameVariables.multiplayer_api.is_multiplayer_host() and not "spatial_offset_pos" in user:
			process_user_join(id, null)
		if not "nodes" in user:
			user["nodes"] = {}
		if parent_node < 0 or parent_node in user["nodes"]:
			var now = OS.get_ticks_msec()
			if not target_node in user["nodes"]:
				user["nodes"][target_node] = {"timestamp": now, "pos": Vector3(0,0,0), "rot": Vector3(0,0,0), "movement": Vector3(0,0,0)}
				emit_signal("add_spatial",id,target_node,node_type, parent_node) 
			user["nodes"][target_node]["timestamp"] = now
			user["nodes"][target_node]["pos"] = pos
			user["nodes"][target_node]["rot"] = rot
			user["nodes"][target_node]["movement"] = movement
		else:
			print ("Can't add node yet: %s"%str(data_object))
	#print ("User List: %s"%str(user_list))



func process_spatial_offset_message(data_object):
	print ("Spatial offset message received: %s"%str(data_object))
	var data = data_object.get("data", {})
	var target_id = data.get("target_id", -1)
	if target_id == self_id:
		var pos = data.get("pos", [0,0,0])
		var rot = data.get("rot", [0,0,0])

		network_pos_offset = Vector3(pos[0], pos[1], pos[2])
		network_rot_offset = Quat(Vector3(rot[0], rot[1], rot[2]))

		$PlayerAreaOffset.rotation = Vector3(0, #fmod(rot[0]+PI,2*PI),
														rot[1], #fmod(rot[1]+PI,2*PI),
														0) # fmod(rot[2]+PI,2*PI))
		$PlayerAreaOffset/PlayerArea.translation = -network_pos_offset
		
		#emit_signal("spatial_offset_message", transform)
		
func process_room_join_message(data_object):
	var room = data_object.get("room", "")
	print ("Room joined %s"%str(data_object))
	is_host = data_object.get("ishost", false)
	is_active = true
	if room:
		emit_signal("room_joined",is_host)
		print ("Room has been joined: %s"%room)
		self.room = room


#The host assigns positions to newly joining users
var user_positions = 1
func process_user_join(user_id, name):
	if not (user_id in user_list):
		user_list[user_id] = {"name":name, "nodes": {}}
	if name != null:
		user_list[user_id]["name"] = name
		
	print ("Users")
	for u in user_list:
		print ("User: #%d  Name: %s"%[u, user_list[u].get("name","no name yet")])
	
	if is_multiplayer_host():
		var user = user_list.get(user_id,null)
		if user == null or not "spatial_offset_pos" in user:
			if user == null:
				user = Dictionary()
			var angle = 0
			var pos = 0
			var dir = 0		

			if user_positions > 1:
				var alternator = int((user_positions-2)/2)
				dir = int((user_positions+2)/4)
				if alternator % 2 == 1:
					dir = -dir
			
			if user_positions % 2 == 1:
				angle = PI
				pos = -9.4
		
			var offset = Vector3(1.5*dir, 0, pos)
			user["spatial_offset_pos"] = offset
			user["spatial_offset_rot"] = Vector3(0,angle, 0)
			
			var message = {"target_id":user_id, "pos": [
				user["spatial_offset_pos"].x,
				user["spatial_offset_pos"].y,
				user["spatial_offset_pos"].z],
				"rot": [
					user["spatial_offset_rot"].x,
					user["spatial_offset_rot"].y,
					user["spatial_offset_rot"].z]
				}
			print ("User %d gets offset: %s"%[user_id, str(message)])
			
			send_message("spatial_offset", message)
			user_list[user_id] = user
			user_positions += 1

func decode_data(data):
	var parse_result = JSON.parse(data)
	if parse_result.error == OK:
		var data_object = parse_result.result
		#print ("Data received: %s"%(data_object.get("type","unknown")))
		match data_object.get("type","unknown"):
			"join":
				print ("User %s joined"%data_object.get("name",""))
				process_user_join(data_object.get("id",0), data_object.get("player_name","Opponent"))
			"user_list":
				var ulist = data_object.get("users",[])
				print ("Current user list: %s"%str(ulist))
				update_users(ulist)
			"move":
				process_move_message(data_object)
			"room_join":
				process_room_join_message(data_object)
			"spatial_remove":
				process_spatial_remove_message(data_object)
			"spatial_offset":
				process_spatial_offset_message(data_object)
			"identity":
				self_id = data_object.get("id",-1)
			"game_message":
				process_game_message(data_object)
			"ping":
				pass
			"unknown":
				continue
			_:
				print ("Unknown message")
				
	#print ("Data received: \n%s"%data)

func _join_room():
	if room:
		send_message("join_room", {"room":room, "player_name": GameVariables.player_name})
	else:
		send_message("create_room", {"player_name": GameVariables.player_name})

# Called when the node enters the scene tree for the first time.
func _ready():
	client.verify_ssl = false
	client.connect("connection_established",self,"_on_connection_established")
	client.connect("connection_error",self,"_on_connection_error")
	client.connect("data_received",self,"_on_data_received")
	client.connect("connection_closed",self,"_on_connection_closed")
	
func connect_to_server(url, room=""):
	print ("Start connection")
	self.room = room
	var error = client.connect_to_url(url)
	print ("Connect call status: %d %d"%[error,OK])

func send_message(type, data):
	var message = {"type":type, "id":self_id, "data": data}
	#print ("Send message: %s"%message)
	send_data(JSON.print(message))

func send_data(data):
	if conn_peer and conn_peer.is_connected_to_host():
		conn_peer.put_packet(data.to_utf8())
	
func disconnect_from_server():
	if conn_peer and conn_peer.is_connected_to_host():
		conn_peer.close()
	
func _on_data_received():
	var data = conn_peer.get_packet().get_string_from_utf8()
	#print ("Message received: %s"%str(data))
	decode_data(data)
	
func _on_connection_established(protocol):
	print ("Connected")
	conn_peer = client.get_peer(1)
	emit_signal("connected")
	_join_room()

func remove_all_users():
	print ("Remove all users")
	var tmp = user_list.keys()
	for u in tmp:
		remove_user(u)
	user_list = Dictionary()

func get_player_name(id):
	var user = user_list.get(id,Dictionary())
	var name = user.get("name", "Player#%d"%id)
	print ("Get player name: %d  %s / %s"%[id, name, str(user_list)])
	return name

func get_scores():
	return $PlayerAreaOffset/PlayerArea.player_scores

func teardown_connection():
	if is_active:
		#This removes all stale nodes
		remove_all_users()
		get_node("PlayerAreaOffset/PlayerArea").remove_all_entities()
		is_active = false
		is_host = false
	emit_signal("room_left")

func _on_connection_error():
	teardown_connection()
	print ("Could not connect")

func _on_connection_closed(was_clean):
	teardown_connection()
	print ("Connection ended")
	
func _on_update_user_points(userid, points, rank):
	$PlayerAreaOffset/PlayerArea._on_update_user_points(userid, points, rank)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	client.poll()
