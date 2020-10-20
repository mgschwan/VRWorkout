extends StaticBody
signal touched

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var touch_begin = 0

func touched_by_controller(obj, root):
	touch_begin = OS.get_ticks_msec()
	print ("Exit button was touched")

func released_by_controller(obj, root):
	var delta = OS.get_ticks_msec() - touch_begin
	if delta > 500:
		print ("Exit touch event")
		emit_signal("touched")

