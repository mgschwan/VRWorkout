extends Control

signal view_changed
signal value_changed


export var value = 20
export var min_v = 0
export var max_v = 100
export var step = 1

func update_display():
	$RichTextLabel.bbcode_text = "[center]%d[/center]"%value
	emit_signal("view_changed")
	
func set_value(value):
	self.value = value
	update_display()
	
func _ready():
	set_value(value)

func _on_Plus_pressed():
	set_value(clamp(value + step, min_v, max_v))
	emit_signal("value_changed", value)

func _on_Minus_pressed():
	set_value(clamp(value - step, min_v, max_v))
	emit_signal("value_changed", value)
