extends Spatial

signal value_changed(value)

export var value = 20
export var min_v = 0
export var max_v = 100
export var step = 1

func get_value():
	return $Viewport/NumberEntry.value

func set_value(value):
	$Viewport/NumberEntry.value = value
	$Viewport/NumberEntry.update_display()

func _on_NumberEntry_view_changed():
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

func _ready():
	$Viewport/NumberEntry.value = value
	$Viewport/NumberEntry.min_v = min_v
	$Viewport/NumberEntry.max_v = max_v
	$Viewport/NumberEntry.step = step
	_on_NumberEntry_view_changed()


func _on_NumberEntry_value_changed(value):
	emit_signal("value_changed",value)
