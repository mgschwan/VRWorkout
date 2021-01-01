extends StaticBody
signal touched

export(int) var msec_delay = 800
var signal_emitted = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _process(delta):
	if touched:
		var dt = OS.get_ticks_msec() - touch_begin
		if dt > msec_delay and not signal_emitted:
			signal_emitted = true
			emit_signal("touched")

var touch_begin = 0
var touched = false
func touched_by_controller(obj, root):
	touch_begin = OS.get_ticks_msec()
	touched = true
	signal_emitted = false

func released_by_controller(obj, root):
	touched = false

