extends Node

class_name SongDatabase

var gu = GameUtilities.new()

var song_database = Dictionary()
var location = "user://song_database.json"


func create_database_entry(song):
	var name = gu.get_song_name(song)
	return {"name": name, "duration": 0, "file": song, "loaded": false}

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
			var audio = gu.load_audio_resource(songfile)
			song_database[songfile]["duration"] = audio.get_length()
			song_database[songfile]["loaded"] = true
			audio = null #Tell the garbage collector to dump that sh
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
