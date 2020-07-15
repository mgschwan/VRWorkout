extends Spatial

signal level_selected(filename, difficulty, level_number)

var current_difficulty = 0

var song_list = []
var song_infos = {}
var page = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func get_song_name(filename):
	var tmp = filename.rsplit(".")[0].rsplit("/")[-1]
	return tmp.replace("_"," ")
	
func update_song_list():
	var offset = page * 6
	var pages = ceil(len(song_list)/6.0)
	for idx in range(6):
		if len(song_list) > idx+offset:
			var filename = song_list[idx+offset]
			var song_name = get_song_name(filename)
			var song_info = song_infos.get(filename,{})
			var artist = song_info.get("artist","")
			get_node("SongBlocks/Element%d"%(idx+1)).set_song_info(song_name,filename,artist)
		else:
			get_node("SongBlocks/Element%d"%(idx+1)).set_song_info("empty",null)
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
				infos[song] = {"artist": artist}
	return infos

func sort_song_list(songs):
	var retVal = []
	var song_dict = {}
	for s in songs:
		var song_name = get_song_name(s)
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

# Called when the node enters the scene tree for the first time.
func _ready():
	var hrr = get_tree().current_scene.get_node("HeartRateReceiver")
	if hrr and hrr.hr_active:
		get_node("DifficultyButtons").enable_automatic(true)
		var nodes = get_node("SongBlocks").get_children()
		for n in nodes:
			if n.has_method("enable_automatic"):
				n.enable_automatic()
	else:
		get_node("DifficultyButtons").enable_automatic(false)

	update_song_list()
	select_difficulty(current_difficulty)


func next_page():
	print ("Page: %d, Songs: %d, Pages: %d"%[page, len(song_list), int(ceil(len(song_list)/6.0))])
	if len(song_list) > 0:
		page = (page + 1) % int(ceil(len(song_list)/6.0))
	print ("Next page: %d"%page)
	update_song_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func select_difficulty(d):
	current_difficulty = d
	get_node("DifficultyButtons").select_difficulty(d)


func _on_level_block_selected(filename, difficulty, level_number):
	if difficulty == null:
		difficulty = current_difficulty
	emit_signal("level_selected", filename, difficulty, level_number)

func _on_NextPage_touched():
	next_page()

var difficulties = {"easy":0,"medium": 1, "hard": 2, "ultra": 3, "auto": -1,}
func _on_DifficultyButtons_difficulty_selected(difficulty):
	if difficulty in difficulties:
		current_difficulty = difficulties[difficulty]

