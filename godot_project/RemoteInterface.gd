extends Node

signal registration_initialized(onetime_code)

var network_server
var network_peer = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var request = null
var api_url = null

# Called when the node enters the scene tree for the first time.
func _ready():
	api_url = ProjectSettings.get("application/config/backend_server")
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self,"_http_connect_request_completed")

func send_data(reference, type, data):
	var query = JSON.print({
		"type": type,
		"reference": reference,
		"value": data		
		})
	var headers = ["Content-Type: application/json"]
	var error = request.request(api_url + "/dataobject/", headers, false, HTTPClient.METHOD_POST, query)
	return error

func _http_connect_request_completed(result, response_code, headers, body):
	print ("Request finished")
	var text = body.get_string_from_utf8()
	print ("Response: %s"%text)
	var response = parse_json(text)
	if response.has("onetime_code"):
		registration_response(response)
	else:
		#Handle other messages
		pass
func registration_response(response):
	emit_signal("registration_initialized",response["onetime_code"])

func register_device(device_id):
	var query = JSON.print({
		"reference": device_id,
		})
	var headers = ["Content-Type: application/json"]
	var error = request.request(api_url + "/registration/", headers, false, HTTPClient.METHOD_POST, query)
	return error
	





# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if network_server.is_connection_available():
#		network_peer = network_server.take_connection()
#	if network_peer != null and network_peer.is_connected_to_host() and network_peer.get_available_bytes() >= 28:
#			var element = network_peer.get_32()
#			var x = network_peer.get_double()
#			var y = network_peer.get_double()
#			var z = network_peer.get_double()
#			print ("Received data %d (%f,%f,%f)"%[element,x,y,z])
