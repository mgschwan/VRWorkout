extends Control


func _input(event):
	print ("Input: %s/%s"%[str(event),str(event.position)])
	
	for b in get_children():
		if b is BaseButton:
			b.pressed = false
	

