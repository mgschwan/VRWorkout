extends Node

signal stream_finished

class_name DummyAudioStream

class DummyStream:
	var stream_duration
	func _init(duration):
		stream_duration = duration
		
	func get_length():
		return stream_duration
		
var start_ts = 0
var stream
var playback_position = 0
var playing = false
var finished_signal_emitted = false

func _process(delta):
	update_playback_position()
	if not finished_signal_emitted and playback_position >= 1000*stream.get_length():
		finished_signal_emitted = true
		emit_signal("stream_finished")

func update_playback_position():
	if playing:
		playback_position = OS.get_ticks_msec() - start_ts

func _init(duration):
	stream = DummyStream.new(duration)

func play():
	playing = true
	finished_signal_emitted = false
	start_ts = OS.get_ticks_msec()
	print ("Stream started")
	
func stop():
	playing = false

func get_playback_position():
	return float(int(playback_position)%int(1000*stream.get_length()))/1000.0
	
	
	

