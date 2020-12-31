extends Spatial

signal level_selected(filename, difficulty, level_number)

var current_difficulty = 0

var song_list = []
var song_infos = {}
var page = 0

var gu = GameUtilities.new()

var playlist = []

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

func update_song_list():
	var offset = page * 6
	var pages = ceil(len(song_list)/6.0)
	for idx in range(6):
		var element = get_node("SongBlocks/Element%d"%(idx+1))
		if len(song_list) > idx+offset:
			var filename = song_list[idx+offset]
			var song_name = gu.get_song_name(filename)
			var song_info = song_infos.get(filename,{})
			var artist = song_info.get("artist","")
			var length = song_info.get("length",0)
			element.is_set = true
			element.set_song_info(song_name,filename,artist,length)
		else:
			element.is_set = false
			element.set_song_info("empty",null)
	get_node("NextPage").print_info("[b]\n  Page %d/%d[b]"%[page+1,pages])

func get_song_infos(songs):
	var infos = {}
	for song in songs:
		var beat_file = File.new()
		var error = beat_file.open("%s.json"%song, File.READ)
		if error == OK:
			var tmp = JSON.parse(beat_file.get_as_text()).result
			beat_file.close()
			if tmp:
				var artist = tmp.get("artist", "")
				var length = tmp.get("length", 0)
				infos[song] = {"artist": artist, "length": length}
	return infos

func sort_song_list(songs):
	var retVal = []
	var song_dict = {}
	for s in songs:
		var song_name = gu.get_song_name(s)
		song_dict[song_name.to_lower()] = s
		
	var song_tmp = song_dict.keys()
	song_tmp.sort()
	for s in song_tmp:
		retVal.append(song_dict[s])
	return retVal

func set_songs(songs):
	song_list = sort_song_list(songs)
	song_infos = get_song_infos(songs)
	update_song_list()


var hrr #Heart rate receiver

func update_automatic():
	if hrr and hrr.hr_active:
		get_node("DifficultyButtons").enable_automatic(true)
		gu.activate_node(get_node("Heartrate"))
	else:
		get_node("DifficultyButtons").enable_automatic(false)
		gu.deactivate_node(get_node("Heartrate"))


# Called when the node enters the scene tree for the first time.
func _ready():
	hrr = get_tree().current_scene.get_node("HeartRateReceiver")
	update_automatic()
	update_song_list()
	update_hr_selectors()
	update_songs()
	select_difficulty(current_difficulty)

func update_songs():
	var t = ""
	var duration = 0
	var songs_tree = get_node("Viewport/CanvasLayer/Songs")
	songs_tree.clear()
	var root = songs_tree.create_item()
	for song in playlist:
		var tmp = songs_tree.create_item()
		tmp.set_text(0, gu.get_song_name(song))
		duration += abs(get_tree().current_scene.get_node("SongDatabase").get_song_duration(song))

	root.set_text(0,"Your Playlist %s"%(gu.seconds_to_timestring(duration)))

	get_node("Viewport").render_target_update_mode = Viewport.UPDATE_ONCE
		
func next_page():
	print ("Page: %d, Songs: %d, Pages: %d"%[page, len(song_list), int(ceil(len(song_list)/6.0))])
	if len(song_list) > 0:
		page = (page + 1) % int(ceil(len(song_list)/6.0))
	print ("Next page: %d"%page)
	update_song_list()


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

func _on_NextPage_touched():
	next_page()

var difficulties = {"easy":0,"medium": 1, "hard": 2, "ultra": 3, "auto": -1,}
func _on_DifficultyButtons_difficulty_selected(difficulty):
	if difficulty in difficulties:
		current_difficulty = difficulties[difficulty]
		if current_difficulty > 1:
			get_tree().current_scene.change_environment("angry")
		else:
			get_tree().current_scene.change_environment("calm")

func update_hr_selectors():
	var hr = ProjectSettings.get("game/target_hr")
	get_node("Heartrate/Button_140").show_selector( hr == 140)
	get_node("Heartrate/Button_150").show_selector( hr == 150)
	get_node("Heartrate/Button_160").show_selector( hr == 160)
	get_node("Heartrate/Button_170").show_selector( hr == 170)
	
func _on_Heartrate_selected(extra_arg_0):
	ProjectSettings.set("game/target_hr",extra_arg_0)
	update_hr_selectors()

func _on_Button_pressed():
	print ("Start button pressed")
	if len(playlist) > 0:
		emit_signal("level_selected", playlist, current_difficulty, 0)

func _on_RemoveButton_pressed():
	print ("Remove button pressed")
	playlist.pop_back()
	update_songs()

func _on_FreeplayButton_pressed():
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

func _on_PauseButton_pressed():
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
