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
		text_node.bbcode_text += "\n\nThis panel shows your achievements"
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
			#print ("Upload achievement")
			var user_id = $SideQuestAPI.sidequest_user_id()
			var app_id = $SideQuestAPI.sidequest_app_id()
			var endpoint = "/users/%s/apps/%s/achievements"%[str(user_id),str(app_id)]
			#print ("Endpoint: %s"%endpoint)
			#print ("Parameters: %s"%parameters)
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
			#print ("Get profile actual")
			var user_id = $SideQuestAPI.sidequest_user_id()
			var endpoint = "/users/%s"%str(user_id)
			$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
			$SideQuestAPI.connect("api_call_complete",self,"_on_profile_call_complete")
			$SideQuestAPI.sidequest_generic_get_request(endpoint)
			while profile_call_inprogress:
				yield(get_tree().create_timer(0.1),"timeout")
	#print ("Get profile finished")

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
		#print ("Get achievements finished")
		achievements.clear()
		if len(data) > 0:
			for entry in data:
				#print ("Achievement: %s"%(entry.get("name","")))
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

#func download_achievement_images():
#	for achievement in achievements:
#		print ("Download achievement %s"%str(achievement))
#		yield(get_image_from_url(achievement.get("image_url")), "completed")


##########################################


var achievement_upload_list = []
func set_achievements(value):
	#print ("Initiate achievements %s"%str(value))
	achievement_upload_list = value
	var co = panel_update()
	if co is GDScriptFunctionState && co.is_valid():
		#print ("Achievement yield until panel finished")
		yield(co, "completed")
	
	
func panel_update():
	#print ("Panel update")
	var co = $SideQuestAPI.wait_until_token_is_valid()
	if co is GDScriptFunctionState && co.is_valid():
		#print ("Yield until token finished")
		yield(co, "completed")
	else:
		#print ("Token not refreshed")
		pass
	#print ("Token refresh complete?")
	if $SideQuestAPI.sidequest_token_valid():
		#print ("Get profile")
		co = get_sidequest_profile()
		if co is GDScriptFunctionState && co.is_valid():
			yield(co, "completed")
		#print ("Upload achievements")
		achievement_upload_list.append({"achievement_identifier":"SIDEQUESTUSER","achieved": true})
		for a in achievement_upload_list:
			co = upload_achievement(a)
			if co is GDScriptFunctionState && co.is_valid():
				yield(co, "completed")
		achievement_upload_list.clear()
		#print ("Get achievements")
		co = get_sidequest_achievements()
		if co is GDScriptFunctionState && co.is_valid():
			yield(co, "completed")
		#print ("Current achievements: %s"%str(achievements))
		#download_achievement_images()
	else:
		print ("Token is not valid")
	update_panel()

func _ready():
	add_child(req)
	achievement_upload_list = GameVariables.game_result.get("achievements",[])
	var co = panel_update()
	if co is GDScriptFunctionState and co.is_valid():
		yield(co,"completed")

	var image_panel = load("res://scenes/RemoteImagePanel.tscn")

	var offset = -0.75
	for achievement in achievements:
		var tmp = image_panel.instance()
		tmp.http_download_url = achievement.get("image_url","")
		#print ("Set download url: %s"%(tmp.http_download_url))
		add_child(tmp)
		tmp.scale.x = 0.25
		tmp.scale.z = 0.25
		tmp.translation.z = 1.5
		tmp.translation.x = offset
		offset += 0.55
	
	
func link():
	if $SideQuestAPI.sidequest_api_idle():
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
		panel_update()
	elif status == $SideQuestAPI.API_CALL_STATUS.FAILED:
		emit_signal("link_failed")	
		panel_update()
