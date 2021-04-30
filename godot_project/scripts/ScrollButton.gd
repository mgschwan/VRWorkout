extends TextureButton

export var scroll_up = false

func _pressed():
	var scroll = get_parent().get_v_scroll()
	print ("Scroll position: %.f"%scroll.value)
	if scroll_up:
		scroll.value = scroll.value - 20
	else:
		scroll.value = scroll.value + 20
	print ("Scroll position: %.f"%scroll.value)
