extends StaticBody
export var song_name = "default"
export var level_number = -1
export var song_filename = ""
export var song_length = 0

var gu = GameUtilities.new()

signal selected(filename, difficulty, level_number)

# Declare member variables here. Examples:

# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	set_text(song_name,"")
	
	gu.deactivate_node(get_node("Text/Easy"))
	gu.deactivate_node(get_node("Text/Medium"))
	gu.deactivate_node(get_node("Text/Hard"))
	gu.deactivate_node(get_node("Text/Auto"))



func set_text(text, artist, duration = 0):
	if duration:
		get_node("Text").print_info("by %s\n[b][i]%s[/i][/b]\n%s"%[artist,text,gu.seconds_to_timestring(duration)])
	else:
		get_node("Text").print_info("by %s\n[b][i]%s[/i][/b]"%[artist,text])

func enable_automatic():
	#Disabled
	#get_node("Text/Auto").show()
	pass

func get_level():
	return level_number
	
#If the whole block is touched get the lowest difficulty
func get_difficulty_selector():
	return 0

func touched_by_controller(obj,root):
	emit_signal("selected",song_filename, null, level_number)
	
func is_in_animation():
	return get_node("AnimationPlayer").is_playing()
	
#Spin the card and set the song info
func set_song_info(text,filename, artist = "", length = 0):
	song_filename = filename
	song_length = length
	get_node("AnimationPlayer").play("spin")	
	#yield(get_tree().create_timer(0.2),"timeout")
	set_text(text, artist, song_length)
	

func _on_difficulty_selected(difficulty):
	print("Selected difficulty")
	emit_signal("selected", song_filename, difficulty, level_number)
