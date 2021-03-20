extends RayCast


var last_viewed = null

func _process(delta):
	var obj = get_collider()
#	if obj:
#		print ("Has collision: %s"%str(obj))
#
	if obj and obj != last_viewed and obj.has_method("empty_input"):
		obj.empty_input()
	last_viewed = null		
	if obj and obj.has_method("visual_input"):
		obj.visual_input()
		last_viewed = obj
