extends Spatial

signal toggled(value)


func set_state(value):
	get_node("Viewport/CanvasLayer/CheckButton").pressed = value
	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE


func _on_CheckButton_pressed():
	var new_state = not get_node("Viewport/CanvasLayer/CheckButton").pressed
	set_state(new_state)
	emit_signal("toggled",new_state)
	get_node("Viewport/CanvasLayer/CheckButton").release_focus()
