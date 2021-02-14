extends Spatial

export(String) var text = ""


func set_text(value):
	$Viewport/RichTextLabel.bbcode_text = value
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _ready():
	var value = text.replace("\\n","\n")
	set_text(value)
	
	
