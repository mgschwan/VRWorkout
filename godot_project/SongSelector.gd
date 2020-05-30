extends Spatial

signal level_selected(filename, difficulty, level_number)


var song_list = []
var song_infos = {}
var page = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func update_song_list():
	var offset = page * 6
	var pages = ceil(len(song_list)/6.0)
	var idx
	for idx in range(6):
		if len(song_list) > idx+offset:
			var filename = song_list[idx+offset]
			var song_name = filename.rsplit(".")[0].rsplit("/")[-1]
			song_name = song_name.replace("_"," ")
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

func set_songs(songs):
	song_list = songs
	song_infos = get_song_infos(songs)
	update_song_list()

# Called when the node enters the scene tree for the first time.
func _ready():
	update_song_list()
	pass # Replace with function body.


func next_page():
	print ("Page: %d, Songs: %d, Pages: %d"%[page, len(song_list), int(ceil(len(song_list)/6.0))])
	if len(song_list) > 0:
		page = (page + 1) % int(ceil(len(song_list)/6.0))
	print ("Next page: %d"%page)
	update_song_list()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_level_block_selected(filename, difficulty, level_number):
	emit_signal("level_selected", filename, difficulty, level_number)

func _on_NextPage_touched():
	next_page()
