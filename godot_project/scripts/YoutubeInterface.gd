extends Spatial


var server = null
var port = 19338
var peer = null
var peer_id = null

var default_length = 99999

var song_position = 0
var song_index = 0
var song_duration = 0
var total_position = 0
var total_duration = default_length
var last_position_update = 0
var update_interval = 0

var should_be_playing = false

var last_ping_received = 0
var last_ping_sent = 0
var ping_interval = 1000

func is_youtube_available():
	return peer != null

func start_server():
	print ("Start server")
		
	server = WebSocketServer.new()
	server.listen(port)
	server.connect("client_connected", self, "_connected")
	server.connect("data_received", self, "_data_received")
	server.connect("client_disconnected", self,"_disconnected")
	print ("Server started")


func _ready():
	start_server()

var teardown_server = false

func disconnect_stale():
	if peer and peer.is_connected_to_host() and peer_id:
		print ("Disconnect stale connection %d %d %d"%[last_ping_sent ,last_ping_received,2*ping_interval])
#		if server:
#			teardown_server = true
#			server.stop()
			
		server.disconnect_peer(peer_id) 
		peer = null
		peer_id = null
		print ("Disconnect initialized")


func _process(delta):
	if server or teardown_server:
		server.poll()
	if teardown_server and not server.has_peer(peer_id):
		print ("Server teardown complete")
		server = null
		peer_id = null
		teardown_server = false
		start_server()
	else:	
		var now = OS.get_ticks_msec()
			
		if last_ping_sent > last_ping_received + 2*ping_interval:
			disconnect_stale()
		elif last_ping_sent + ping_interval < now:
			ping()
			last_ping_sent = now

func _disconnected(id, clean_close):
	print ("Connection disconnected")
	disconnect_stale()
	
func _on_game_pause():
	if should_be_playing:
		peer.put_packet(JSON.print({"cmd":"pause"}).to_utf8())

func _on_game_unpause():
	if should_be_playing:
		peer.put_packet(JSON.print({"cmd":"resume"}).to_utf8())

func ping():
	if peer:
		peer.put_packet(JSON.print({"cmd":"ping"}).to_utf8())
		return true
	return false
	
func play():
	should_be_playing = true
	if peer:
		print ("Play has been called")
		total_position = 0
		peer.put_packet(JSON.print({"cmd":"play"}).to_utf8())
		return true
	return false
	
func stop():
	should_be_playing = false
	print ("Youtube wants to stop")
	if peer:
		peer.put_packet(JSON.print({"cmd":"stop"}).to_utf8())
		return true
	return false

func _connected(id, protocol):
	print ("Client connected")
	if server:
		last_ping_received = OS.get_ticks_msec()
		peer = server.get_peer(id)
		peer_id = id
		if not should_be_playing:
			stop()
		
		#This is a hack to avoid the connection issues after 10 minnutes		
		######yield(get_tree().create_timer(45.0),"timeout")
		######disconnect_stale()
	
	
func _data_received(id):
	print ("Data received")		
	var packet = peer.get_packet()
	#print (packet.get_string_from_ascii())
	var result = parse_json(packet.get_string_from_utf8())
	var t = result.get("type","")
	if t == "playback_update":
		song_position = result.get("position",0)
		song_index = result.get("song_idx",0)
		song_duration = result.get("duration",0)
		total_position = result.get("total_position",0)
		update_interval = result.get("update_interval",0)
		last_position_update = OS.get_ticks_msec()
	elif t == "song_info":
		total_duration = float(result.get("total_duration",default_length))
	elif t == "ping":
		last_ping_received = OS.get_ticks_msec()

#This is only for testing
func _input(ev):
	if not GameVariables.vr_mode:
		if ev is InputEventKey:
			if ev.scancode == KEY_C and ev.pressed:
				disconnect_stale()

