extends Panel

signal add_playlist_song (song_filename)
signal preview_song (song_filename)
signal freeplay()
signal resting()


var song_list = []
var song_infos = {}
var page = 0

var gu = GameUtilities.new()

func update_song_list():
	var offset = page * 6
	$SongList.clear()
	for idx in range(len(song_list)):
		var filename = song_list[idx]
		var song_name = gu.get_song_name(filename)
		var song_info = song_infos.get(filename,{})
		var artist = song_info.get("artist","")
		var length = get_tree().current_scene.get_node("SongDatabase").get_song_duration(filename)
		$SongList.add_item("%s - %s by %s"%[gu.seconds_to_timestring(length), song_name, artist])

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
				infos[song] = {"artist": artist, "length": 0}
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


func _ready():
		
	var external_dir = ProjectSettings.get("game/external_songs")
	
	if external_dir:
		$Label.text = "Place custom OGG or MP3 files in: %s"%external_dir
		
	
	pass


func _on_Add_pressed():
	var items = $SongList.get_selected_items()
	if len(items) > 0:
		var idx = items[0]
		var song_file = song_list[idx] 
		emit_signal("add_playlist_song", song_file)

func _on_Preview_pressed():
	var items = $SongList.get_selected_items()
	if len(items) > 0:
		var idx = items[0]
		var song_file = song_list[idx] 
		emit_signal("preview_song", song_file)


func _on_StopPreview_pressed():
	emit_signal("preview_song", null)


func _on_Freeplay_pressed():
	emit_signal("freeplay")


func _on_Resting_pressed():
	emit_signal("resting")
