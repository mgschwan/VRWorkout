extends Spatial



signal state_change_completed

var music_volume = 0
var inside_sfx = false

func say(text):
	var active = ProjectSettings.get("game/instructor")
	if active:
		if text == "keep it up":
			play_sfx("keep_it_up")
		elif text == "go for it":
			play_sfx("go_for_it")
		elif text == "go go go":
			play_sfx("go_go_go")
		elif text == "very good":
			play_sfx("very_good")
		elif text == "faster":
			play_sfx("faster")
		elif text == "thats the spirit":
			play_sfx("thats_the_spirit")
		elif text == "you are on a roll":
			play_sfx("you_are_on_a_roll")
		elif text == "pulled_ahead":
			play_sfx("pulled_ahead")
		elif text == "falling_behind":
			play_sfx("falling_behind")
		elif text == "i want to see those knees higher":
			play_sfx("i_want_to_see_those_knees_higher")
		

func play_sfx(name):
	if not inside_sfx:
		inside_sfx = true
		music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -6)
	get_node(name).play()

func _on_sfx_finished():
	if inside_sfx:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
		music_volume = 0
		inside_sfx = false
