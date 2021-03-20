extends StaticBody

signal viewing()
signal not_viewing()

func visual_input():
	emit_signal("viewing")
	
func empty_input():
	emit_signal("not_viewing")
