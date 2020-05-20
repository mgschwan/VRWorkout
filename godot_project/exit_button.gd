extends StaticBody
signal touched

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func touched_by_controller(obj, root):
	print ("Exit button was touched")
	emit_signal("touched")
