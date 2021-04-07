extends Spatial

class_name YoutubeStreamInterface

signal stream_finished
var finished_signal_emitted = false
var start_ts = 0
var playback_position = 0
var playing = true
var stream
var interface
var duration = 0

func _ready():
	interface = get_tree().current_scene.get_node("YoutubeInterface")
	

func _process(delta):
	update_playback_position()
	if not finished_signal_emitted and playback_position >= 1000 * stream.get_length():
		print ("Emit signal stream finished")
		finished_signal_emitted = true
		emit_signal("stream_finished")

var hold_time = false
func update_playback_position():
	var now = OS.get_ticks_msec()
	if playing:
		var tmp_position = now - start_ts
		
		if not hold_time and tmp_position < (interface.total_position - 0.1)*1000.0:
			#print ("We've fallen behind, timewarp")
			start_ts = now - interface.total_position * 1000.0 
			tmp_position = now - start_ts
	
		if tmp_position > interface.total_position*1000.0 + 2 * interface.update_interval:
			hold_time = true
			#print ("We've run ahead, hold %.2f %.2f %.2f"%[tmp_position, interface.total_position*1000.0 + 2 * interface.update_interval, start_ts])
		elif not hold_time:
			playback_position = tmp_position
		
		if hold_time and playback_position <= interface.total_position*1000.0:
			#The stream has catched up
			start_ts = now - playback_position
			hold_time = false
		
			
func play():
	playing = true
	finished_signal_emitted = false
	interface.play()
	start_ts = OS.get_ticks_msec()
	print ("Stream started")

func stop():
	print ("YoutubeInterface STOP")
	interface.stop()
	playing = false

func get_playback_position():
	return float(int(playback_position)%int(1000*stream.get_length()))/1000.0



