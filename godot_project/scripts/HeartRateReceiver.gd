extends Node

var vrhealthAPI = null

signal heart_rate_received(hr)

var port = 9988
var server = WebSocketServer.new()
var peer = null
var last_received = 0
var message_interval_limit = 1000
var hr_active = false

#Check if script exists and if it does load it
func load_VRHealthAPI():
	var script_file = "res://scripts/3rdparty/VRHealthAPIConnect.gd"
	if ResourceLoader.exists(script_file):
		vrhealthAPI = Node.new()
		vrhealthAPI.script = load(script_file)
	else:
		print ("VRHealth API not available")

# Called when the node enters the scene tree for the first time.
func _ready():
	load_VRHealthAPI()
	if vrhealthAPI:	
		print ("Loading Oculus Quest VRHealth settings")
		vrhealthAPI.loadConnection(ProjectSettings.get("application/config/vrhealth_config"))
		add_child(vrhealthAPI)
		vrhealthAPI.connect("heart_rate_received", self, "process_heartrate")	
		vrhealthAPI.connectLive()
	server.listen(port)
	server.connect("client_connected", self, "_connected")
	server.connect("data_received", self, "_data_received")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _process(delta):
	server.poll()
	
func _connected(id, protocol):
	print ("Client connected")
	peer = server.get_peer(id)

func _data_received(id):
	print ("Data received")		
	var packet = peer.get_packet()
	print (packet.get_string_from_ascii())
	var hr = int(packet.get_string_from_ascii())

	process_heartrate(hr)

func process_heartrate(hr):
	var now = OS.get_ticks_msec() 
	if now > last_received + message_interval_limit:
		hr_active = true
		print ("Heartrate received %s"%str(hr))
		emit_signal("heart_rate_received",hr)
		last_received = now
	else:
		print ("Limit heart rate interval")
	
