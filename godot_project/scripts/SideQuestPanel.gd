extends Spatial

signal link_shortcode(code, url)
signal link_finished()
signal link_failed()

var profile = {}
var achievements = []

onready var text_node = get_node("Viewport/CanvasLayer/Text")
onready var achievements_node = get_node("Viewport/CanvasLayer/Achievements")

func update_panel():
	if $SideQuestAPI.sidequest_is_connected():
		var username = profile.get("name", "SideQuest Player")
		text_node.bbcode_text = "Welcome %s"%username
	else:
		text_node.bbcode_text = "You are not connected to SideQuest\n\nGo to the Connections Settings"
	achievements_node.bbcode_text = "Your achievements\n\n"
	for achievement in achievements:
		achievements_node.bbcode_text += "[center]%s[/center]\n"%(achievement.get("name",""))

func _on_profile_call_complete(status, data):
	if status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		profile = data
		get_sidequest_achievements()
	elif status == $SideQuestAPI.API_CALL_STATUS.FAILED:
		profile = {}
	
func get_sidequest_profile():
	if $SideQuestAPI.sidequest_is_connected():
		var user_id = $SideQuestAPI.sidequest_user_id()
		var endpoint = "/users/%s"%str(user_id)
		$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
		$SideQuestAPI.connect("api_call_complete",self,"_on_profile_call_complete")
		$SideQuestAPI.sidequest_generic_get_request(endpoint)

func _on_initialize_token_complete(status ,data):
	get_sidequest_profile()
	
func initialize_panel():
	if $SideQuestAPI.sidequest_is_connected():
		$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
		$SideQuestAPI.connect("api_call_complete",self,"_on_initialize_token_complete")
		$SideQuestAPI.sidequest_token()

func _achievement_result(status,data):
	if status == $SideQuestAPI.API_CALL_STATUS.SUCCESS:
		achievements.clear()
		if len(data) > 0:
			for entry in data:
				var achievement = {"name":"","image_url":"","achievement_identifier":""}
				achievement["image_url"] = entry.get("image", "")
				achievement["name"] = entry.get("name", "")
				achievement["achievement_identifier"] = entry.get("achievement_identifier", "")
				achievements.append(achievement)
	update_panel()


func get_sidequest_achievements():
	if $SideQuestAPI.sidequest_is_connected():
		var user_id = $SideQuestAPI.sidequest_user_id()
		var app_id = $SideQuestAPI.sidequest_app_id()
		var endpoint = "/users/%s/apps/%s/achievements"%[str(user_id),str(app_id)]
		$SideQuestAPI.disconnect_all_connections($SideQuestAPI,"api_call_complete")
		$SideQuestAPI.connect("api_call_complete",self,"_achievement_result")
		$SideQuestAPI.sidequest_generic_get_request(endpoint)

##########################################










func _ready():
	initialize_panel()
	
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
	elif status == $SideQuestAPI.API_CALL_STATUS.FAILED:
		emit_signal("link_failed")	
		
