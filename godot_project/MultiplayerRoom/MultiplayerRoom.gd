extends Node

signal user_join(id, name)
signal user_leave(id)
signal add_spatial(userid, nodeid, type, parent_node)
signal remove_spatial(userid, nodeid)
signal connected()
signal room_joined(as_host)
signal room_left()
signal game_message(userid, data)


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
		user_list[id] = {"name":name, "nodes": {}}
		if new_user and id != self_id:
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

func send_move_message(node, parent, node_type, movement_vector):
	var pos_update = {"nodeid":node.get_instance_id(),"parent": parent,
													  "type" : node_type,
													  "pos": [node.translation.x,
														  node.translation.y,
														  node.translation.z],
												      "rot": [node.rotation.x,
														  node.rotation.y,
														  node.rotation.z],
													  "movement": [movement_vector.x,
														   movement_vector.y,
														movement_vector.z]}
	self.send_message("move", pos_update)

func process_spatial_remove_message(data_object):
	var data = data_object.get("data", {})
	var id = data_object.get("id",-1)
	var target_node = data.get("nodeid","root")
	var user = user_list.get(id,null)
	if user and id != self_id:
		if "nodes" in user:
			if target_node in user["nodes"]:
				#user["nodes"][target_node] = {"pos": Vector3(0,0,0), "rot": Vector3(0,0,0)}
				user["nodes"].erase(target_node)
				emit_signal("remove_spatial",id,target_node) 
				
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

func process_room_join_message(data_object):
	var room = data_object.get("room", "")
	print ("Room joined %s"%str(data_object))
	is_host = data_object.get("ishost", false)
	is_active = true
	if room:
		emit_signal("room_joined",is_host)
		print ("Room has been joined: %s"%room)
		self.room = room

func decode_data(data):
	var parse_result = JSON.parse(data)
	if parse_result.error == OK:
		var data_object = parse_result.result
		match data_object.get("type","unknown"):
			"join":
				print ("User %s joined"%data_object.get("name",""))
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
		send_message("join_room", {"room":room})
	else:
		send_message("create_room", Dictionary())

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


func teardown_connection():
	if is_active:
		#This removes all stale nodes
		remove_all_users()
		get_node("PlayerArea").remove_all_entities()
		is_active = false
		is_host = false
	emit_signal("room_left")

func _on_connection_error():
	teardown_connection()
	print ("Could not connect")

func _on_connection_closed(was_clean):
	teardown_connection()
	print ("Connection ended")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	client.poll()
