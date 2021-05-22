extends StaticBody

signal viewing()
signal not_viewing()

	
func empty_input():
	emit_signal("not_viewing")
