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

var actual_audio_stream
var dummy_audio_stream 
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

var is_dummy_stream = false

var root

func play_current_song():
	var song_file = playlist[current_index]

	if is_dummy_stream and dummy_audio_stream:
		dummy_audio_stream.queue_free()
	elif actual_audio_stream:
		print ("Stop old audio")
		actual_audio_stream.stop()
		actual_audio_stream.queue_free()
		
	
	if typeof(song_file) == TYPE_REAL or typeof(song_file) == TYPE_INT:
		dummy_audio_stream = DummyAudioStream.new(abs(song_file))
		current_audio_resource = dummy_audio_stream.stream
		dummy_audio_stream.connect("stream_finished",self,"_on_item_finished")
		add_child(dummy_audio_stream)
		is_dummy_stream = true
		dummy_audio_stream.play()
		print ("Dummy stream: %.2f"%song_file)
	elif song_file.find("youtube://") == 0:
		current_audio_resource = DummyAudioStream.DummyStream.new( root.get_node("YoutubeInterface").total_duration)
		dummy_audio_stream = YoutubeStreamInterface.new()
		dummy_audio_stream.connect("stream_finished",self,"_on_item_finished")
		dummy_audio_stream.stream = current_audio_resource
		add_child(dummy_audio_stream)
		is_dummy_stream = true
		dummy_audio_stream.play()		
	else:
		current_audio_resource = gu.load_audio_resource(song_file)
		current_audio_resource.loop = false
		actual_audio_stream = AudioStreamPlayer.new()
		actual_audio_stream.bus = "Music"
		actual_audio_stream.stream = current_audio_resource
		actual_audio_stream.connect("finished",self,"_on_item_finished")
		add_child(actual_audio_stream)

		is_dummy_stream = false
		
		if start_ts < 0:
			start_ts = OS.get_ticks_msec()/1000.0

		var actual_playback_position = (OS.get_ticks_msec()/1000.0) - start_ts
		var skip_time = max(0,actual_playback_position - item_offset_ts)
		actual_audio_stream.play(skip_time)
		print ("skip: %.4f"%skip_time)

func _on_item_finished():		
	print ("Item finished")
	if current_index+1 < len(playlist):
		current_index += 1
		if current_audio_resource:
			item_offset_ts += current_audio_resource.get_length()
		print ("Play song #%d"%current_index)
		play_current_song()		
	else:
		playing = false
		emit_signal("stream_finished")

func _process(delta):
	pass
func _ready():
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

	#print ("Beats pre adjust: %s"%str(beats))

	for idx in range(len(beats)):
		beats[idx] = beats[idx] + offset

	#print ("Beats post adjust: %s"%str(beats))
	
	return beats
		
	
func _init(songs, r):
	var duration = 0
	root = r
	for s in songs:
		var offset = duration
		var song_length = 0
		var has_beats = true

		if typeof(s) == TYPE_REAL or typeof(s) == TYPE_INT:
			song_length = abs(s)
			if s <= 0:
				has_beats = false
		else:
			if s.find("youtube://") == 0:
				# audio = YoutubeInterface.stream
				song_length = root.get_node("YoutubeInterface").total_duration
			else:
				var audio = gu.load_audio_resource(s)
				song_length = audio.get_length()
		
		duration += song_length
		
		if has_beats:
			var beats = load_beatlist(s, offset, song_length)
			playlist_beats += beats

		playlist.append(s)
		durations.append(song_length)
		
	stream = CombinedStream.new(duration)

func play():
	if len(playlist) > 0:
		playing = true
		play_current_song()
	finished_signal_emitted = false

func stop():
	print ("Stop called")
	if actual_audio_stream:
		actual_audio_stream.stop()
	if dummy_audio_stream:
		dummy_audio_stream.stop()
	playing = false

func get_playback_position():
	var pos = 0
	if is_dummy_stream and dummy_audio_stream:
		pos = dummy_audio_stream.get_playback_position()
	elif actual_audio_stream:
		pos = actual_audio_stream.get_playback_position()
	return item_offset_ts + pos
	
	
	




