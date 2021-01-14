extends Spatial

signal link_shortcode(code, url)
signal link_finished()
signal link_failed()
signal image_download_complete()

var req = HTTPRequest.new()
var profile = {}
var achievements = []

onready var text_node = get_node("Viewport/CanvasLayer/Text")
onready var achievements_node = get_node("Viewport/CanvasLayer/Achievements")

func update_panel():
	if $SideQuestAPI.sidequest_is_connected():
		var username = profile.get("name", "SideQuest Player")
		text_node.bbcode_text = "Welcome %s"%username
		text_node.bbcode_text += "\nTo take part in the SideQuest Fitness Week select the SideQuest Workout to your right and add songs of at least 6 minutes. Achieve a score of at least 60"	
	else:
		text_node.bbcode_text = "You are not connected to SideQuest\n\nGo to the Connections Settings"
	achievements_node.bbcode_text = "[center]Your achievements[/center]\n\n"
	for achievement in achievements:
		achievements_node.bbcode_text += "[center]%s[/center]\n"%[achievement.get("name","")]

	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE

############################################################

var achievement_upload_inprogress = false

func _on_achievement_upload_complete(status, data):
	if status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		print ("Achievement upload success %s"%str(data))
	else:
		print("Achievement upload failed")
	achievement_upload_inprogress = false	
		
func upload_achievement(parameters):
	if $SideQuestAPI.sidequest_is_connected():
		if $SideQuestAPI.sidequest_token_valid():
			achievement_upload_inprogress = true
			print ("Upload achievement")
			var user_id = $SideQuestAPI.sidequest_user_id()
			var app_id = $SideQuestAPI.sidequest_app_id()
			var endpoint = "/users/%s/apps/%s/achievements"%[str(user_id),str(app_id)]
			print ("Endpoint: %s"%endpoint)
			print ("Parameters: %s"%parameters)
			$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
			$SideQuestAPI.connect("api_call_complete",self,"_on_achievement_upload_complete")
			$SideQuestAPI.sidequest_generic_post_request(endpoint, parameters)
			
			while achievement_upload_inprogress:
				yield(get_tree().create_timer(0.1),"timeout")

			
			
###########################################################

var profile_call_inprogress = false

func _on_profile_call_complete(status, data):
	if status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		profile = data
	elif status == $SideQuestAPI.API_CALL_STATUS.FAILED:
		profile = {}
	profile_call_inprogress = false
	
func get_sidequest_profile():
	if not profile_call_inprogress:
		profile_call_inprogress = true
		if $SideQuestAPI.sidequest_is_connected():
			print ("Get profile actual")
			var user_id = $SideQuestAPI.sidequest_user_id()
			var endpoint = "/users/%s"%str(user_id)
			$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
			$SideQuestAPI.connect("api_call_complete",self,"_on_profile_call_complete")
			$SideQuestAPI.sidequest_generic_get_request(endpoint)
			while profile_call_inprogress:
				yield(get_tree().create_timer(0.1),"timeout")
	print ("Get profile finished")

############################################################

#func _on_initialize_token_complete(status ,data):
#	get_sidequest_profile()
#
#func initialize_panel():
#		if $SideQuestAPI.sidequest_is_connected():
#		$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
#		$SideQuestAPI.connect("api_call_complete",self,"_on_initialize_token_complete")
#		$SideQuestAPI.sidequest_token()

var get_achievement_inprocess = false

func _achievement_result(status,data):
	if status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		print ("Get achievements finished")
		achievements.clear()
		if len(data) > 0:
			for entry in data:
				print ("Achievement: %s"%(entry.get("name","")))
				var achievement = {"name":"","image_url":"","achievement_identifier":""}
				achievement["image_url"] = entry.get("image", "")
				achievement["name"] = entry.get("name", "")
				achievement["achievement_identifier"] = entry.get("achievement_identifier", "")
				achievements.append(achievement)
				
	get_achievement_inprocess = false

func get_sidequest_achievements():
	if $SideQuestAPI.sidequest_is_connected():
		if $SideQuestAPI.sidequest_token_valid():
			get_achievement_inprocess = true
			var user_id = $SideQuestAPI.sidequest_user_id()
			var app_id = $SideQuestAPI.sidequest_app_id()
			var endpoint = "/users/%s/apps/%s/achievements"%[str(user_id),str(app_id)]
			$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
			$SideQuestAPI.connect("api_call_complete",self,"_achievement_result")
			$SideQuestAPI.sidequest_generic_get_request(endpoint)
			while get_achievement_inprocess:
				yield(get_tree().create_timer(0.1),"timeout")



#########################################


var http_download_url = ""

func download_achievement_images():
	for achievement in achievements:
		print ("Download achievement %s"%str(achievement))
		get_image_from_url(achievement.get("image_url"))
	

func get_cache_filename(fname):
	return "user://download_cache/%s"%fname

func get_resource_filename(fname):
	return "res://download_cache/%s"%fname

func get_filename_from_url(url):
	var fname = url.get_file()
	if fname and not fname.ends_with(".png"):
		fname = "%s.png"%fname
	return fname
	
func save_url_image(image, url):
	var d = Directory.new()
	d.open("user://")
	if not d.dir_exists("download_cache"):
		print ("Create cache")
		d.make_dir("download_cache")
	else:
		print ("Cache exists")
	
	var fname = get_filename_from_url(url)
	print ("Save filename: %s"%fname)
	if fname:
		print ("Take over path")
		image.save_png(get_cache_filename(fname))

func _image_http_download_finished(result, response_code, headers, body):
	var image = Image.new()
	var error = ERR_CANT_OPEN
	if http_download_url.ends_with(".png"):
		error = image.load_png_from_buffer(body)
	elif http_download_url.ends_with(".jpg"):
		error = image.load_jpg_from_buffer(body)
		
	if error != OK:
		push_error("Couldn't load the image.")
	else:
		save_url_image(image, http_download_url)
	emit_signal("image_download_complete")

func get_image_from_url(url):	
	$SideQuestAPI.disconnect_all_connections(req,"request_completed")
	req.connect("request_completed",self,"_image_http_download_finished")
	http_download_url = url

	var error = req.request(url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	else:
		emit_signal("image_download_complete")


##########################################


var achievement_upload_list = []
func set_achievements(value):
	print ("Initiate achievements %s"%str(value))
	achievement_upload_list = value
	var co = panel_update()
	if co is GDScriptFunctionState && co.is_valid():
		print ("Achievement yield until panel finished")
		yield(co, "completed")
	
	
func panel_update():
	print ("Panel update")
	var co = $SideQuestAPI.wait_until_token_is_valid()
	if co is GDScriptFunctionState && co.is_valid():
		print ("Yield until token finished")
		yield(co, "completed")
	else:
		print ("Token not refreshed")
	print ("Token refresh complete?")
	if $SideQuestAPI.sidequest_token_valid():
		print ("Get profile")
		co = get_sidequest_profile()
		if co is GDScriptFunctionState && co.is_valid():
			yield(co, "completed")
		print ("Upload achievements")
		for a in achievement_upload_list:
			co = upload_achievement(a)
			if co is GDScriptFunctionState && co.is_valid():
				yield(co, "completed")
		achievement_upload_list.clear()
		print ("Get achievements")
		co = get_sidequest_achievements()
		if co is GDScriptFunctionState && co.is_valid():
			yield(co, "completed")
		print ("Current achievements: %s"%str(achievements))
		#download_achievement_images()
	else:
		print ("Token is not valid")
	update_panel()

func _ready():
	add_child(req)
	achievement_upload_list = GameVariables.game_result.get("achievements",[])
	panel_update()

	
func link():
	$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
	$SideQuestAPI.connect("api_call_complete",self,"_on_SideQuestAPI_api_call_complete")
	$SideQuestAPI.sidequest_link()

func _on_SideQuestAPI_api_call_complete(status, data):
	if status == $SideQuestAPI.API_CALL_STATUS.PROGRESS:
		#We got an intermediary result
		if data.has("code") and data.has("link_url"):
			emit_signal("link_shortcode",data.get("code",""),data.get("link_url",""))
	elif status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		emit_signal("link_finished")
		set_achievements([{"achievement_identifier":"SIDEQUESTUSER","achieved":true}])
	elif status == $SideQuestAPI.API_CALL_STATUS.FAILED:
		emit_signal("link_failed")	
		
