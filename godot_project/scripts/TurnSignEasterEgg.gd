extends StaticBody

func touched_by_controller(obj, root):
	print ("Easteregg change AR Mode")
	GameVariables.ar_mode = not GameVariables.ar_mode
