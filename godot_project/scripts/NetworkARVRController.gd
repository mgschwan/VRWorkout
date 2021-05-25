extends Spatial

var port = 21110
var server = WebSocketServer.new()
var peer = null
var last_received = 0

var message_count = 0
var calibrated = false

# Called when the node enters the scene tree for the first time.
func _ready():
	server.listen(port)
	server.connect("client_connected", self, "_connected")
	server.connect("data_received", self, "_data_received")

var throttle_counter = 0
func _process(delta):
	server.poll()
	
	throttle_counter += 1
	if throttle_counter > 20:
		throttle_counter = 0
		var now = OS.get_ticks_msec()
		
		if now < last_received + 1000 and not $Mesh.visible:
			$Mesh.show()
		elif OS.get_ticks_msec() > last_received + 1000 and $Mesh.visible:
			$Mesh.hide()
		
		#Do stuff less often
		pass

func _connected(id, protocol):
	print ("Client connected")
	calibrated = false
	message_count = 0
	peer = server.get_peer(id)

func _data_received(id):
	var packet = peer.get_packet()
	var data = packet.get_string_from_ascii()
	#print ("Position message received %s"%data)
	process_controller_message(data)

var calibrated_offset_quaternion = Quat.IDENTITY
var calibrated_offset_origin = Vector3(0,0,0)

func process_controller_message(data):
	var result = parse_json(data)
	if result:
		if result.get("type","") == "pos":
			last_received = OS.get_ticks_msec()
			
			var tracking_src = result.get("src","none")
			if (tracking_src == "cam" or tracking_src == "full"):
				if not $Mesh/Phone.visible:
					$Mesh/Phone.show()
				if $Mesh/Compass.visible:
					$Mesh/Compass.hide()
			elif tracking_src == "imu":
				if $Mesh/Phone.visible:
					$Mesh/Phone.hide()
				if not $Mesh/Compass.visible:
					$Mesh/Compass.show()
				
			var x = result.get("x",0.0)
			var y = result.get("y",0.0)
			var z = result.get("z",0.0)
			var controller_trans = Vector3(x,y,z)
			
			var qx = result.get("qx",0.0)
			var qy = result.get("qy",0.0)
			var qz = result.get("qz",0.0)
			var qw = result.get("qw",1.0)
			var controller_quat = Quat(qx,qy,qz,qw) 
			message_count += 1
			if message_count > 50 and not calibrated:
				var cam_transform = get_viewport().get_camera().global_transform
				
				calibrated_offset_origin = controller_trans - cam_transform.origin
				calibrated_offset_quaternion = controller_quat.inverse() * cam_transform.basis.get_rotation_quat()
				#print ("%s / %s / %s"%[str(controller_quat), str(cam_transform.basis.get_rotation_quat()), str(calibrated_offset_quaternion)])

				calibrated = true
				print ("Calibrated")


			$Mesh.global_transform.origin = controller_trans - calibrated_offset_origin
			$Mesh.global_transform.basis = Basis(controller_quat * calibrated_offset_quaternion)




