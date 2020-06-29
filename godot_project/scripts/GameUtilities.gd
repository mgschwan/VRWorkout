extends Object

class_name GameUtilities

func seconds_to_timestring(total):
	var minutes = int(total/60)
	var seconds = int(total)%60
	return "%02d:%02d"%[minutes,seconds]

func get_device_id():
	return OS.get_unique_id()
