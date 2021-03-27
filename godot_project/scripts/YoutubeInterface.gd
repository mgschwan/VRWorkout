extends Spatial


var server = WebSocketServer.new()
var port = 19338
var peer = null

var default_length = 99999

var song_position = 0
var song_index = 0
var song_duration = 0
var total_position = 0
var last_position_update = 0
var update_interval = 0

var should_be_playing = false

var last_ping_received = 0
var last_ping_sent = 0
var ping_interval = 1000

func is_youtube_available():
	return peer != null

func _ready():
	server.listen(port)
	server.connect("client_connected", self, "_connected")
	server.connect("data_received", self, "_data_received")
	server.connect("client_disconnected", self,"_disconnected")
	
func _process(delta):
	server.poll()
	var now = OS.get_ticks_msec()
		
	if last_ping_sent > last_ping_received + 2*ping_interval:
		if peer and peer.is_connected_to_host():
			print ("Disconnect stale connection %d %d %d"%[last_ping_sent ,last_ping_received,2*ping_interval])
			peer.close()
			peer = null

	if last_ping_sent + ping_interval < now:
		ping()
		last_ping_sent = now



func _disconnected(id, clean_close):
	peer = null

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
	last_ping_received = OS.get_ticks_msec()
	peer = server.get_peer(id)
	if not should_be_playing:
		stop()
	
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
	elif t == "ping":
		last_ping_received = OS.get_ticks_msec()
