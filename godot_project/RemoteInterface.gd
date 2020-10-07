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

	print ("API url: %s"%api_url)
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", self,"_http_connect_request_completed")

func send_data(reference, type, data):
	var error = ERR_UNAVAILABLE
	if ProjectSettings.get("game/portal_connection"):
		print ("Sending data to portal")
		var query = JSON.print({
			"type": type,
			"reference": reference,
			"value": data		
			})
		var headers = ["Content-Type: application/json"]
		error = request.request(api_url + "/dataobject/", headers, false, HTTPClient.METHOD_POST, query)
	else:
		print ("Data not sent. Connection not active")
	return error

func get_request(path):
	var error = ERR_UNAVAILABLE
	if ProjectSettings.get("game/portal_connection"):
		print ("Send GET request portal")
		error = request.request(api_url + path)
	else:
		print ("Data not sent. Connection not active")
	return error


func _http_connect_request_completed(result, response_code, headers, body):
	print ("Request finished")
	var text = body.get_string_from_utf8()
	print ("Response: %s"%text)
	var response = parse_json(text)
	if response:
		if response.has("onetime_code"):
			registration_response(response)
		elif response.has("message_type") and response["message_type"] == "profile":
			profile_response(response)
		elif response.has("public_handle"):
			dataobject_response(response)
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

var data_object_query_active = false
var data_object_query_result = null


func get_public_dataobject(handle, result):
	var retVal = null
	#Why this yield? Because it seems if the response is already there or error
	#the function never yields and the parent can't yield on completion?
	yield(get_tree().create_timer(0.01),"timeout")
	while data_object_query_active:
		yield(get_tree().create_timer(0.01),"timeout")

	data_object_query_active = true	
	print ("Get public data object: %s"%handle)
	var error = get_request("/public_dataobject/%s/"%handle)

	if error == OK:
		print ("Waiting for response")
		while data_object_query_result == null:
			yield(get_tree().create_timer(0.01),"timeout")				
		print ("Response received")
	else:
		print ("Request failed")
	retVal = data_object_query_result
	data_object_query_result = null
	data_object_query_active = false
	result["dataobject"] = retVal
	
	
	
func request_profile(device_id):
	print ("Request profile for: %s"%device_id)
	get_request("/profile/%s/"%device_id)
	
func profile_response(response):
	if "name" in response:
		GameVariables.player_name = response["name"]
		GameVariables.challenge_slots = JSON.parse(response.get("challenges","{}")).result

func dataobject_response(response):
	data_object_query_result = JSON.parse(response.get("value","{}")).result
	print ("Dataobject result: %s"%str(data_object_query_result))


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
