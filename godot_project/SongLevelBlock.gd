extends StaticBody
export var song_name = "default"
export var level_number = -1

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Text").print_info("[b][i][color=black]%s[/color][/i][/b]"%song_name)
	pass # Replace with function body.

func get_level():
	return level_number
	
#If the whole block is touched get the lowest difficulty
func get_difficulty_selector():
	return 0
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
