extends Spatial

signal level_selected(filename, difficulty, level_number)
signal content_changed()

var current_difficulty = 0

var song_list = []
var song_infos = {}
var page = 0

var gu = GameUtilities.new()

var playlist = []

func playlist_from_song_files(songs):
	playlist.clear()
	for song in songs:
		if get_tree().current_scene.get_node("SongDatabase").valid_song(song):
				playlist.append(song)	
	update_songs()

func playlist_from_song_names(songs):
	playlist.clear()
	print ("Playlist from songs: %s"%str(songs))
	for song in songs:
		if typeof(song) == TYPE_REAL or typeof(song) == TYPE_INT:
			playlist.append(song)
		else:
			var songfile = get_tree().current_scene.get_node("SongDatabase").get_songfile(song)
			if songfile:
				playlist.append(songfile)
	update_songs()

func set_playlist(songs):
	playlist = songs
	update_songs()

func set_songs(songs):
	$SongSelector/Viewport/SongSelection.set_songs(songs)
	$SongSelector/Viewport.render_target_update_mode = Viewport.UPDATE_ONCE

var hrr #Heart rate receiver

func update_automatic():
	if hrr and hrr.hr_active:
		get_node("DifficultyButtons").enable_automatic(true)
	else:
		get_node("DifficultyButtons").enable_automatic(false)

# Called when the node enters the scene tree for the first time.
func _ready():
	hrr = get_tree().current_scene.get_node("HeartRateReceiver")

	update_automatic()
	update_songs()
	select_difficulty(current_difficulty)
	emit_signal("content_changed")
	
func update_songs():
	var t = ""
	var duration = 0
	var songs_tree = get_node("Viewport/CanvasLayer/TabContainer/Playlist/Songs")
	songs_tree.clear()
	var root = songs_tree.create_item()
	if len(playlist) > 0:
		get_node("Viewport/CanvasLayer/TabContainer/Playlist/Instruction").hide()
	else:
		get_node("Viewport/CanvasLayer/TabContainer/Playlist/Instruction").show()
		
	for song in playlist:
		var tmp = songs_tree.create_item()
		tmp.set_text(0, gu.get_song_name(song))
		duration += abs(get_tree().current_scene.get_node("SongDatabase").get_song_duration(song))

	root.set_text(0,"Total duration %s"%(gu.seconds_to_timestring(duration)))

	print ("Update songs: changed")
	emit_signal("content_changed")
	#get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE

var frame_idx = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	frame_idx += 1
	if frame_idx > 20:
		update_automatic()
		frame_idx = 0
		
func select_difficulty(d):
	current_difficulty = d
	get_node("DifficultyButtons").select_difficulty(d)

func _on_level_block_selected(filename, difficulty, level_number):
	playlist.append(filename)
	update_songs()

var difficulties = {"easy":0,"medium": 1, "hard": 2, "ultra": 3, "auto": -1,}
func _on_DifficultyButtons_difficulty_selected(difficulty):
	if difficulty in difficulties:
		current_difficulty = difficulties[difficulty]
#		if current_difficulty > 1:
#			get_tree().current_scene.change_environment("angry")
#		elif current_difficulty > 0:
#			get_tree().current_scene.change_environment("bright")
#		else:
#			get_tree().current_scene.change_environment("calm")


func _on_Start_pressed():
	print ("Start button pressed")
	if len(playlist) > 0:
		emit_signal("level_selected", playlist, current_difficulty, 0)

func _on_Remove_pressed():
	print ("Remove button pressed")
	playlist.pop_back()
	update_songs()


func _on_YoutubeButton_pressed():
	playlist.clear()
	playlist.append("youtube://")
	emit_signal("level_selected", playlist, current_difficulty, 0)

func _on_ActivateYoutube_pressed():
	print ("Activate Youtube")
	var link = "%s%d"%[ProjectSettings.get("application/config/youtube_link"),OS.get_unix_time()]
	OS.shell_open(link)
	emit_signal("content_changed")

func _on_SongSelection_add_playlist_song(song_filename):
	playlist.append(song_filename)
	update_songs()

var preview_song_playing = null
func _on_SongSelection_preview_song(song_filename):
	if preview_song_playing == null and song_filename:
		preview_song_playing = song_filename
		var stream = gu.load_audio_resource(song_filename)
		$AudioStreamPlayer.stream = stream
		$AudioStreamPlayer.play()
	else:
		preview_song_playing = null
		$AudioStreamPlayer.stop()


func _on_TabContainer_tab_selected(tab):
	if tab == 0:
		$SongSelector.enable()
	else:
		$SongSelector.disable()


func hide_panels():
	$StaticBody/CollisionShape.disabled = true
	$SongSelector/CollisionShape.disabled = true	
	self.hide()

func show_panels():
	$StaticBody/CollisionShape.disabled = false
	$SongSelector/CollisionShape.disabled = false	
	self.show()



func _on_Freeplay_pressed():
	var complete = false
	if playlist:
		var last = playlist.back()
		if typeof(last) == TYPE_REAL or typeof(last) == TYPE_INT:
			if last > 0:
				playlist[-1] = last + 300
				complete = true
	if not complete:
		playlist.append(300)
	update_songs()


func _on_Resting_pressed():
	var complete = false
	if playlist:
		var last = playlist.back()
		if typeof(last) == TYPE_REAL or typeof(last) == TYPE_INT:
			if last <= 0:
				playlist[-1] = last - 10
				complete = true
	if not complete:
		playlist.append(-10)
	update_songs()

func _on_TabContainer_content_changed():
	print ("Tab container changed")
	emit_signal("content_changed")
