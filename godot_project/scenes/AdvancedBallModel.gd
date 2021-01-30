extends Spatial

export(Color) var color
export(String) var text = "HR 99"

func _ready():
	get_node("Viewport/CanvasLayer/ColorRect").color = color
	update_display()
	
func update_display():
	get_node("Viewport/CanvasLayer/RichTextLabel").bbcode_text="[center]%s[/center]"%text
	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE
	
func set_info(value):
	text = value
	update_display()
