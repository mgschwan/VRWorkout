extends Control

export(String) var server_url 

signal content_changed()

var req = HTTPRequest.new()

func _ready():
	set_text("")
	add_child(req)
	req.connect("request_completed", self, "_http_request_completed")
	get_welcome_message()

func _process(delta):
	pass

func get_welcome_message():
	if server_url:
		var error = req.request("%s?device=%s"%[server_url,GameVariables.device_id])
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func set_text(value):
	$RichTextLabel.bbcode_text = value
	emit_signal("content_changed")
	
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if response_code >= 200 and response_code < 300:
		print ("Welcome message received")
		var response = body.get_string_from_utf8()
		set_text(response)
	else:
		print ("Could not load message")		
	
