extends Spatial

export(String) var server_url 

var req = HTTPRequest.new()

func _ready():
	set_text("")
	add_child(req)
	req.connect("request_completed", self, "_http_request_completed")
	get_welcome_message()

var frame_limiter = 0
var current_line = 0
var direction = 1
func _process(delta):
#	frame_limiter += 1
#	if frame_limiter > 10:
#		var first_limit = $Viewport/RichTextLabel.get_visible_line_count()
#		var second_limit = $Viewport/RichTextLabel.get_line_count() - $Viewport/RichTextLabel.get_visible_line_count()
#		second_limit = max (second_limit, first_limit+1)
#
#		frame_limiter = 0
#		current_line = clamp(current_line+direction, first_limit, second_limit)
#		if current_line <= first_limit:
#			direction = 1
#		elif current_line >= second_limit - 1:
#			 direction = -1
#
#		$Viewport/RichTextLabel.scroll_to_line(current_line)
#		$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	pass

func get_welcome_message():
	if server_url:
		var error = req.request("%s?device=%s"%[server_url,GameVariables.device_id])
		if error != OK:
			push_error("An error occurred in the HTTP request.")

func set_text(value):
	$Viewport/RichTextLabel.bbcode_text = value
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	if response_code >= 200 and response_code < 300:
		print ("Welcome message received")
		var response = body.get_string_from_utf8()
		set_text(response)
	else:
		print ("Could not load message")		
	

func scroll_element(direction):
	var first_limit = $Viewport/RichTextLabel.get_visible_line_count()-2
	var second_limit = $Viewport/RichTextLabel.get_line_count() - $Viewport/RichTextLabel.get_visible_line_count()
	second_limit = max (second_limit, first_limit+1)

	current_line = clamp(current_line+direction, max(0,first_limit), second_limit)

	$Viewport/RichTextLabel.scroll_to_line(int(current_line))
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
	

var scroll_speed = 0.1
func _on_Viewing_ScrollDown():
	scroll_element(scroll_speed)

func _on_NotViewing_ScrollDown():
	pass # Replace with function body.


func _on_Viewing_ScrollUp():
	scroll_element(-scroll_speed)

func _on_NotViewing_ScrollUp():
	pass # Replace with function body.





