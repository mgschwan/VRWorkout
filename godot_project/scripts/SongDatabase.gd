extends Node

class_name SongDatabase

var gu = GameUtilities.new()

var song_database = Dictionary()
var location = "user://song_database.json"


func create_database_entry(song):
	var name = gu.get_song_name(song)	
	var duration = 0
	var loaded = false
	
	return {"name": name, "duration": duration, "file": song, "loaded": loaded}

#If it's a string then find the actual filename, if it's a number then it's actually
#not a song but either a rest or freeplay period
func get_songfile(name):
	var retVal = ""
	
	if typeof(name) == TYPE_REAL or typeof(name) == TYPE_INT:
		return retVal
		
	for song in song_database:
		if song_database[song].get("name","") == name:
			retVal = name
			break
	return retVal

func get_song_duration(songfile):
	var duration = 0

	if typeof(songfile) == TYPE_REAL or typeof(songfile) == TYPE_INT:
		return songfile

	if song_database.has(songfile):
		if not song_database.get(songfile).get("loaded", false):
			var loaded = false
			var beat_file = File.new()
			var beat_filename = "%s.json"%str(songfile)
			if beat_file.file_exists(beat_filename):
				var error = beat_file.open(beat_filename, File.READ)
				if error == OK:
					var tmp = JSON.parse(beat_file.get_as_text()).result
					beat_file.close()
					var tmp_duration = float(tmp.get("length",0))
					song_database[songfile]["duration"] = tmp_duration
					song_database[songfile]["loaded"] = true
					loaded = true
					print ("Use beat file %s (%f)"%[beat_filename,tmp_duration])
			if not loaded:
				var audio = gu.load_audio_resource(songfile)
				song_database[songfile]["duration"] = audio.get_length()
				song_database[songfile]["loaded"] = true
				audio = null #Tell the garbage collector to dump that sh
				print ("Use real audio file for duration")

		duration = song_database.get(songfile,{"duration":0}).get("duration",0)
		
	return duration	
		
func valid_song(songfile):
	var retVal = false
	if typeof(songfile) == TYPE_REAL or typeof(songfile) == TYPE_INT:
		retVal = true
	else:
		if song_database.has(songfile):
			retVal = true		
	return retVal
		
func song_list():
	return song_database.keys()

func intialize_song_database():
	#Moved out of the _ready function so the game does not immediately crash
	#on game start if there is an error in song loading
	print ("Initializing song database")

	print ("Loading external songs: %s"%ProjectSettings.get("game/external_songs"))
	
	var local_song_database = gu.load_persistent_config(location)
	var songs = []
	songs += gu.get_song_list("res://audio/songs")
	songs += gu.get_song_list("res://audio/nonfree_songs")
	var external_dir = ProjectSettings.get("game/external_songs")
	
	if external_dir:
		songs += gu.get_song_list(external_dir)

	for song in songs:
		if local_song_database.has(song):
			song_database[song] = local_song_database[song]
		else:
			song_database[song] = create_database_entry(song)

	gu.store_persistent_config(location, song_database)

	print ("Song database initialized (%d songs)"%(len(song_database)))

func _ready():
	pass
