extends Spatial

var gu = GameUtilities.new()

export var row_elements = 2

var image_panel = load("res://scenes/RemoteImagePanel.tscn")


func update_achievements():
	var achievements = gu.load_persistent_config(GameVariables.achievement_file_location)
	var row = 0
	var col = 0

	var children = $Anchor.get_children()
	for n in children:
		n.queue_free()

	for id in achievements.keys():
		var name = GameVariables.achievement_displays[id].get("name","")
		var image_url = GameVariables.achievement_displays[id].get("image_url","")
		
		var tmp = image_panel.instance()
		tmp.http_download_url = image_url
		$Anchor.add_child(tmp)
		tmp.scale.x = 0.15
		tmp.scale.z = 0.15
		tmp.rotation.y = -PI/2
		tmp.translation.z = -row*0.4 + 0.2
		tmp.translation.x = col*0.4 + 0.2
		col += 1
		if col >= row_elements:
			col = 0
			row += 1

func _ready():
	update_achievements()


