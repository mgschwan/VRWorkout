extends StaticBody
signal touched

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _process(delta):
	if touched:
		var dt = OS.get_ticks_msec() - touch_begin
		if dt > 800:
			print ("Exit touch event")
			emit_signal("touched")

var touch_begin = 0
var touched = false
func touched_by_controller(obj, root):
	touched = true
	touch_begin = OS.get_ticks_msec()


func released_by_controller(obj, root):
	touched = false

