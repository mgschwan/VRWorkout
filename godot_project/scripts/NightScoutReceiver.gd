extends Node

var url = null #"https://arakon.herokuapp.com/pebble"

var update_interval = 60000

var last_request = 0

func _ready():
	$HTTPRequest.connect("request_completed", self, "_http_request_completed")
	request_data()

var frame_throttle = 0
func _process(delta):
	frame_throttle += 1
	if frame_throttle > 50:
		frame_throttle = 0
		var now = OS.get_ticks_msec()
		if now > last_request + update_interval:
			request_data() 
			last_request = now
			
var request_in_process = false
func request_data():
	if url and not request_in_process:
		request_in_process = true
		# Perform a GET request. The URL below returns JSON as of writing.
		var error = $HTTPRequest.request(url)
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	request_in_process = false
	if response_code >= 200 and response_code < 300:
		var response = parse_json(body.get_string_from_utf8())
		if typeof(response) == TYPE_DICTIONARY:
			var status = response.get("status",[]).front()
			var now = 0
			if status:
				now = status.get("now",0)
			
			var bgs = response.get("bgs",[]).front()
			var bgdelta = 0
			var datetime = 0
			var direction = "unknown"
			var sgv = 133
			var trend = 0
			if bgs:
				bgdelta = bgs.get("bgdelta",0)
				datetime = bgs.get("datetime",0)
				direction = bgs.get("direction","unknown")
				sgv = bgs.get("sgv",0)
				trend = bgs.get("trend",0)

			GameVariables.plugin_data["nightscout"] = {"now":now,
													"bgdelta": bgdelta,
													"datetime": datetime,
													"direction": direction,
													"sgv": sgv,
													"trend": trend}

		print (str(response))	
	
