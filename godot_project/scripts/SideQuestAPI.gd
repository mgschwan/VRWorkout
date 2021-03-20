extends Node

class_name SideQuestAPI

signal api_call_complete(status, data)

var token_valid = false

var api_endpoint = ProjectSettings.get("application/config/sidequest_api_endpoint")	
#var api_endpoint = "http://127.0.0.1:8889"
var client_id = ProjectSettings.get("application/config/sidequest_client_id")

var scopes = "scopes[0]=user.basic_profile.read&scopes[1]=user.app_achievements.read&scopes[2]=user.app_achievements.write"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var config_store = "user://sidequest_link.json"

var sidequest_connection = {}

enum API_CALL_STATUS {
	SUCCESS,
	PROGRESS,
	FAILED	
}

enum SQ_API {
	GET_SHORTCODE,
	CHECK_SHORTCODE,
	GET_TOKEN,
	GENERIC_GET_REQUEST,
	GENERIC_POST_REQUEST,
	FAILED
}

enum API_STATE {
	IDLE,
	TIMEOUT,
	SQ_LINK_REQUEST_1,
	SQ_LINK_REQUEST_2,
	SQ_LINK_REQUEST_3,
	SQ_LINK_REQUEST_4,
	SQ_LINK_REQUEST_FINISHED,
	SQ_LINK_REQUEST_FAILED,
	SQ_TOKEN_REQUEST_1,
	SQ_TOKEN_REQUEST_2,
	SQ_TOKEN_REQUEST_FAILED,
	SQ_TOKEN_REQUEST_FINISHED,
	SQ_GET_REQUEST_1,
	SQ_GET_REQUEST_2,
	SQ_GET_REQUEST_FAILED,
	SQ_GET_REQUEST_FINISHED,
	SQ_POST_REQUEST_1,
	SQ_POST_REQUEST_2,
	SQ_POST_REQUEST_FAILED,
	SQ_POST_REQUEST_FINISHED,
	}


var http_req = HTTPRequest.new()
var request_inprocess = false
var request_type 

var current_api_state = API_STATE.IDLE

# res = requests.post("https://api.sidetestvr.com/v2/oauth/getshortcode",data={"client_id": client_id, "scopes": [] })
# res.content
# res2 = requests.post("https://api.sidetestvr.com/v2/oauth/checkshortcode", data={"code": "840015", device_id:"ba9525e247f095c4dd2c2f0c51483f0a990e1277"})
# res2.content


# Called when the node enters the scene tree for the first time.
func _ready():
	sidequest_connection =  load_persistent_config(config_store)
	add_child(http_req)
	http_req.connect("request_completed",self,"_http_request_completed")
	
	
var last_api_state_change = 0
var state_timeout = 10000
var last_api_state = null

func _process(delta):	
	var now = OS.get_ticks_msec()
	if last_api_state != current_api_state:
		last_api_state_change = now
		last_api_state = current_api_state
	
	if current_api_state != null and current_api_state != API_STATE.IDLE:
		if now > last_api_state_change + state_timeout:
			current_api_state = API_STATE.TIMEOUT
	
	#State machine
	if current_api_state == API_STATE.SQ_LINK_REQUEST_1:
		api_request_shortcode()
	elif current_api_state == API_STATE.SQ_LINK_REQUEST_2:
		if request_type == SQ_API.FAILED:
			current_api_state = API_STATE.SQ_LINK_REQUEST_FAILED
	elif current_api_state == API_STATE.SQ_LINK_REQUEST_3:
		emit_signal("api_call_complete",API_CALL_STATUS.PROGRESS, {"code": sidequest_connection.get("code",""), "link_url": sidequest_connection.get("link_url","")})
		api_check_shortcode()
	elif current_api_state == API_STATE.SQ_LINK_REQUEST_FINISHED:
		print ("Linking Finished")
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.SUCCESS, {})
		store_persistent_config(config_store, sidequest_connection)
	elif current_api_state == API_STATE.SQ_LINK_REQUEST_FAILED:
		print ("Error: Could not retrieve link code")
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.FAILED, {})
	elif current_api_state == API_STATE.SQ_TOKEN_REQUEST_1:
		api_request_token()
	elif current_api_state == API_STATE.SQ_TOKEN_REQUEST_2:
		if request_type == SQ_API.FAILED:
			current_api_state = API_STATE.SQ_TOKEN_REQUEST_FAILED
	elif current_api_state == API_STATE.SQ_TOKEN_REQUEST_FAILED:
		current_api_state = API_STATE.IDLE	
		emit_signal("api_call_complete",API_CALL_STATUS.FAILED, {})
	elif current_api_state == API_STATE.SQ_TOKEN_REQUEST_FINISHED:
		print ("Get Token finished")
		store_persistent_config(config_store, sidequest_connection)
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.SUCCESS, {})
	elif current_api_state == API_STATE.SQ_GET_REQUEST_1:
		api_generic_get_request()
	elif current_api_state == API_STATE.SQ_GET_REQUEST_2:
		if request_type == SQ_API.FAILED:
			current_api_state = API_STATE.SQ_GET_REQUEST_FAILED
	elif current_api_state == API_STATE.SQ_GET_REQUEST_FAILED:
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.FAILED, {})
	elif current_api_state == API_STATE.SQ_GET_REQUEST_FINISHED:
		current_api_state = API_STATE.IDLE
		#print ("Generic GET request finished\n%s"%(str(generic_get_result)))
		emit_signal("api_call_complete",API_CALL_STATUS.SUCCESS, generic_get_result)
	elif current_api_state == API_STATE.SQ_POST_REQUEST_1:
		api_generic_post_request()
	elif current_api_state == API_STATE.SQ_POST_REQUEST_2:
		if request_type == SQ_API.FAILED:
			current_api_state = API_STATE.SQ_POST_REQUEST_FAILED
	elif current_api_state == API_STATE.SQ_POST_REQUEST_FAILED:
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.FAILED, {})		
	elif current_api_state == API_STATE.SQ_POST_REQUEST_FINISHED:
		#print ("Generic POST request finished\n%s"%(str(generic_post_result)))
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.SUCCESS, generic_post_result)
	elif current_api_state == API_STATE.TIMEOUT:
		print ("Timeout")
		http_req.cancel_request()
		request_inprocess = false
		current_api_state = API_STATE.IDLE
		emit_signal("api_call_complete",API_CALL_STATUS.FAILED, {})
			
func _http_request_completed(result, response_code, headers, body):
	#print ("Request completed %s"%(str(response_code)))
	request_inprocess = false
	if response_code >= 200 and response_code < 300:
		if request_type == SQ_API.GET_SHORTCODE:
			get_shortcode_response(body)
		elif request_type == SQ_API.CHECK_SHORTCODE:
			print ("Link code: %s (%s)"%[sidequest_connection.get("code",""),sidequest_connection.get("link_url","")])
			check_shortcode_response(body)
		elif request_type == SQ_API.GET_TOKEN:
			get_token_response(body)
		elif request_type == SQ_API.GENERIC_GET_REQUEST:
			generic_get_response(body)
		elif request_type == SQ_API.GENERIC_POST_REQUEST:
			generic_post_response(body)
	elif response_code == 401:
		print ("Token needs refreshing")
		token_valid = false
	elif response_code == 409 and request_type == SQ_API.GENERIC_POST_REQUEST:
		#That happens if an achievement is uploaded that already exists
		generic_post_response(body)
	else:
		#print ("Request failed\n%s"%body.get_string_from_utf8())
		request_type = SQ_API.FAILED
	
func sidequest_user_id():
	return sidequest_connection.get("user_id",-1)	
	
func sidequest_app_id():
	return sidequest_connection.get("app_id",-1)	

func sidequest_is_connected():
	var rt = sidequest_connection.get("refresh_token","")
	print ("Is connected? RT: %s"%rt)	 
	return (rt != "")
	

##############################################################
###### SideQuest Linking
##############################################################
func get_shortcode_response(body):
	var decoded = parse_json(body.get_string_from_utf8())
	if decoded.get("code",""):
		sidequest_connection["code"] = decoded.get("code","")
		sidequest_connection["device_id"] = decoded.get("device_id","")
		sidequest_connection["link_url"] = decoded.get("verification_url","")
		current_api_state = API_STATE.SQ_LINK_REQUEST_3
	else:
		current_api_state = API_STATE.SQ_LINK_REQUEST_FAILED

func check_shortcode_response(body):
	var decoded = parse_json(body.get_string_from_utf8())
	if body and decoded.get("refresh_token",""):
		sidequest_connection["access_token"] = decoded.get("accessToken","")
		sidequest_connection["refresh_token"] = decoded.get("refreshToken","")
		sidequest_connection["app_id"] = decoded.get("apps_id","")
		sidequest_connection["user_id"] = decoded.get("users_id","")
		sidequest_connection["scopes"] = decoded.get("scopes","")
		sidequest_connection["access_token_expires"] = decoded.get("access_token_expires","")
		sidequest_connection["refresh_token_expires"] = decoded.get("refresh_token_expires","")		
		token_valid = true
		print ("Auth: %s"%str(decoded))
		current_api_state = API_STATE.SQ_LINK_REQUEST_FINISHED
	else:
		current_api_state = API_STATE.SQ_LINK_REQUEST_3


func api_request_shortcode():
	if not request_inprocess:
		current_api_state = API_STATE.SQ_LINK_REQUEST_2
		request_inprocess = true
		request_type = SQ_API.GET_SHORTCODE
		var ret = http_req.request("%s/oauth/getshortcode"%api_endpoint, ["Content-Type: application/x-www-form-urlencoded"], true, HTTPClient.METHOD_POST, "client_id=%s&%s"%[client_id,scopes])
		if ret != OK:		
			print ("Could not send request %s"%str(ret))

func api_check_shortcode():
	if not request_inprocess:
		current_api_state = API_STATE.SQ_LINK_REQUEST_4
		token_valid = false
		request_inprocess = true
		request_type = SQ_API.CHECK_SHORTCODE
		var data = {"code": sidequest_connection.get("code",""), "device_id": sidequest_connection.get("device_id","")}	
		var ret = http_req.request("%s/oauth/checkshortcode"%api_endpoint, ["Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(data))
		if ret != OK:		
			print ("Could not send request %s"%str(ret))

func sidequest_link():
	print ("Clear sidequest connection. Start linking")	
	if current_api_state == API_STATE.IDLE:
		sidequest_connection = {}
		current_api_state = API_STATE.SQ_LINK_REQUEST_1

func sidequest_api_idle():
	return (current_api_state == API_STATE.IDLE)

##############################################################
###### SideQuest Token
##############################################################

#Request a new access_token
func sidequest_token():
	print ("Start Token Request")
	if current_api_state == API_STATE.IDLE:
		token_valid = false
		current_api_state = API_STATE.SQ_TOKEN_REQUEST_1
	
func get_token_response(body):
	var decoded = parse_json(body.get_string_from_utf8())
	if body and decoded.get("access_token",""):
		sidequest_connection["access_token"] = decoded.get("accessToken","")
		sidequest_connection["user_id"] = decoded.get("users_id","")
		sidequest_connection["access_token_expires"] = decoded.get("access_token_expires","")
		print ("Auth: %s"%str(decoded))
		token_valid = true
		current_api_state = API_STATE.SQ_TOKEN_REQUEST_FINISHED
	else:
		current_api_state = API_STATE.SQ_TOKEN_REQUEST_FAILED

func api_request_token():
	if not request_inprocess:
		current_api_state = API_STATE.SQ_TOKEN_REQUEST_2
		request_inprocess = true
		request_type = SQ_API.GET_TOKEN
		var data = "client_id=%s&refresh_token=%s&grant_type=%s"%[client_id, sidequest_connection.get("refresh_token",""), "refresh_token"]
		var ret = http_req.request("%s/oauth/token"%api_endpoint, ["Content-Type: application/x-www-form-urlencoded"], true, HTTPClient.METHOD_POST, data)
		if ret != OK:		
			print ("Could not send request %s"%str(ret))

func sidequest_token_valid():
	return token_valid

func wait_until_token_is_valid():
	var success = false
	var max_retries = 100
	if not sidequest_token_valid():
		api_request_token()	
	while max_retries > 0:
		if sidequest_token_valid() and current_api_state == API_STATE.IDLE:
			success = true
			break
		elif not request_inprocess:
			#API request has finished without success
			break
		yield(get_tree().create_timer(0.1),"timeout")	
		max_retries -= 1
	return success
	
##############################################################
###### SideQuest GenericGetRequest
##############################################################

var generic_get_endpoint = ""
var generic_get_result = {}

func sidequest_generic_get_request(endpoint):
	#print ("Start Generic GET Request")
	if current_api_state == API_STATE.IDLE:
		generic_get_endpoint = endpoint
		current_api_state = API_STATE.SQ_GET_REQUEST_1
	else:
		print ("API busy state: %s"%str(current_api_state))
func generic_get_response(body):
	var decoded = parse_json(body.get_string_from_utf8())
	if body and decoded:
		generic_get_result = decoded
		current_api_state = API_STATE.SQ_GET_REQUEST_FINISHED
	else:
		current_api_state = API_STATE.SQ_GET_REQUEST_FAILED


func api_generic_get_request():
	if not request_inprocess:
		current_api_state = API_STATE.SQ_GET_REQUEST_2
		request_inprocess = true
		request_type = SQ_API.GENERIC_GET_REQUEST
		var ret = http_req.request("%s%s"%[api_endpoint,generic_get_endpoint], ["Authorization: Bearer %s"%sidequest_connection.get("access_token","")], true, HTTPClient.METHOD_GET)
		if ret != OK:		
			print ("Could not send request %s"%str(ret))

##############################################################
###### SideQuest GenericPostRequest
##############################################################

var generic_post_endpoint = ""
var generic_post_parameters = {}
var generic_post_result = {}


func sidequest_generic_post_request(endpoint, parameters):
	#print ("Start Generic POST Request")
	if current_api_state == API_STATE.IDLE:
		generic_post_endpoint = endpoint
		generic_post_parameters = parameters
		current_api_state = API_STATE.SQ_POST_REQUEST_1
		
func generic_post_response(body):
	var decoded = parse_json(body.get_string_from_utf8())
	generic_post_result = decoded
	current_api_state = API_STATE.SQ_POST_REQUEST_FINISHED
	
func api_generic_post_request():
	if not request_inprocess:
		current_api_state = API_STATE.SQ_POST_REQUEST_2
		request_inprocess = true
		request_type = SQ_API.GENERIC_POST_REQUEST
		var url = "%s%s"%[api_endpoint,generic_post_endpoint]
		#print ("Posting to: %s  (%s)"%[url,str(generic_post_parameters)])
		var ret = http_req.request(url, ["Authorization: Bearer %s"%sidequest_connection.get("access_token",""),"Content-Type: application/json"], true, HTTPClient.METHOD_POST, to_json(generic_post_parameters))
		if ret != OK:		
			print ("Could not send request %s"%str(ret))


############################################################

#Disconnect all connections for a certain signal
func disconnect_all_connections(node, signal_):
	#print ("Disconnect: %s -> %s"%[str(node), str(signal_)])
	var connections = node.get_signal_connection_list(signal_)
	for s in connections:
		 node.disconnect(s["signal"], s["target"], s["method"])

#Stores a config dict to disk
func store_persistent_config(location, parameters):
		var config_file = File.new()
		var error = config_file.open(location, File.WRITE)
		if error == OK:
				var tmp = JSON.print(parameters)
				config_file.store_string(tmp)
				config_file.close()
				print ("Config saved")
		else:
				print ("Could not save config")

func load_persistent_config(location):
		var config_file = File.new()
		var error = config_file.open(location, File.READ)
		var parameters = {}

		if error == OK:
				var tmp = JSON.parse(config_file.get_as_text()).result
				config_file.close()
				if tmp:
				   parameters = tmp
				print ("Config loaded")
		else:
				print ("Could not open config")

		return parameters






