extends TabContainer

signal start_pressed()
signal remove_pressed()

signal activate_youtube()
signal start_youtube()

signal content_changed()

var youtube = null


func _ready():
	youtube = get_tree().current_scene.get_node("YoutubeInterface")


var frame_idx = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame_idx += 1
	if frame_idx > 20:
		if youtube.is_youtube_available() and not $Youtube/YoutubeButton.visible:
			#print ("Youtube available")
			$Youtube/YoutubeButton.show()
			$Youtube/ActivateYoutube.hide()
			emit_signal("content_changed")
		elif not youtube.is_youtube_available() and $Youtube/YoutubeButton.visible:
			#print ("Youtube not available")
			$Youtube/YoutubeButton.hide()
			$Youtube/ActivateYoutube.show()
			emit_signal("content_changed")
		frame_idx = 0




func _on_StartButton_pressed():
	emit_signal("start_pressed")


func _on_RemoveButton_pressed():
	emit_signal("remove_pressed")


func _on_YoutubeButton_pressed():
	emit_signal("start_youtube")

func _on_ActivateYoutube_pressed():
	emit_signal("activate_youtube")


func _on_Content_changed():
	emit_signal("content_changed")
