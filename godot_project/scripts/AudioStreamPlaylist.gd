extends Node

signal stream_finished

class_name AudioStreamPlaylist

var gu = GameUtilities.new()

class CombinedStream:
	var stream_duration
	func _init(duration):
		stream_duration = duration
		
	func get_length():
		return stream_duration

var actual_audio_stream = AudioStreamPlayer.new()
var current_audio_resource

var playlist = []
var durations = []
var playlist_beats = []
var current_index = 0
var item_offset_ts = 0
var start_ts = -1

var stream
var playback_position = 0
var playing = false
var finished_signal_emitted = false

func play_current_song():
	actual_audio_stream.stop()
	current_audio_resource = gu.load_audio_resource(playlist[current_index])
	print ("Audio resource. Next playlist item: %s %f"%[str(current_audio_resource),current_audio_resource.get_length()])
	actual_audio_stream.stream = current_audio_resource
	if start_ts < 0:
		start_ts = OS.get_ticks_msec()/1000.0
	var actual_playback_position = (OS.get_ticks_msec()/1000.0) - start_ts
	var skip_time = max(0,actual_playback_position - item_offset_ts)
	actual_audio_stream.play()
	print ("Is playing: %s (skip: %.4f)"%[str(actual_audio_stream.playing),skip_time])

func _on_item_finished():
	if current_index+1 < len(playlist):
		current_index += 1
		if current_audio_resource:
			item_offset_ts += current_audio_resource.get_length()
		play_current_song()		
	else:
		playing = false
		emit_signal("stream_finished")
		
func _process(delta):
	pass

func _ready():
	actual_audio_stream.bus = "Music"
	pass	
	
func load_beatlist (song, offset = 0, duration = 0):
	var beats = []
	
	
	var beat_file = File.new()
	var error = beat_file.open("%s.json"%str(song), File.READ)

	if error == OK:
		var tmp = JSON.parse(beat_file.get_as_text()).result
		beat_file.close()
		beats = tmp.get("beats", [])
		print ("%d beats loaded"%len(beats))
	else: 
		print ("Could not open beat list")

	#If the song has no beats use the default beats
	if (GameVariables.override_beatmap or len(beats) == 0):
		beats = []
		var bpm = ProjectSettings.get("game/bpm")
		var delta = max(0.1, 60.0/float(max(1,bpm)))
		var now = OS.get_ticks_msec()
		var pos = 0
		#get the correct starting time
		#var elapsed = (now - first_beat)/1000.0
		#pos =  (ceil(elapsed/delta) - elapsed/delta)*delta
		#print ("Start at: %.2f"%pos)
			
		while pos < duration-delta:
			beats.append(pos)
			pos += delta

	print ("Beats pre adjust: %s"%str(beats))

	for idx in range(len(beats)):
		beats[idx] = beats[idx] + offset

	print ("Beats post adjust: %s"%str(beats))
	
	return beats
		
	
func _init(songs):
	actual_audio_stream.connect("finished",self,"_on_item_finished")
	add_child(actual_audio_stream)

	var duration = 0
	for s in songs:
		var offset = duration

		var audio = gu.load_audio_resource(s)
		duration += audio.get_length()

		var beats = load_beatlist(s, offset, audio.get_length())
		playlist_beats += beats

		playlist.append(s)
		durations.append(audio.get_length())
	stream = CombinedStream.new(duration)

func play():
	playing = true
	play_current_song()
	finished_signal_emitted = false

func stop():
	actual_audio_stream.stop()
	playing = false

func get_playback_position():
	return item_offset_ts + actual_audio_stream.get_playback_position()
	
	
	




