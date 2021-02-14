extends Node2D

signal view_changed
signal value_changed


export var value = 20
export var min_v = 0
export var max_v = 100
export var step = 1

func update_display():
	$RichTextLabel.bbcode_text = "[center]%d[/center]"%value
	emit_signal("view_changed")
	
func _ready():
	update_display()

func _on_Plus_pressed():
	value = clamp(value + step, min_v, max_v)
	update_display()
	emit_signal("value_changed", value)

func _on_Minus_pressed():
	value = clamp(value - step, min_v, max_v)
	update_display()
	emit_signal("value_changed", value)
