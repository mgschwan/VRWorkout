extends Spatial

var runtime = 0
var groove = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	update_trophies()

func update_trophies():
	get_node("Runtime").set_text("[b][i][color=gray]Running time[/color][/i][b]\n\n[b]%d seconds[/b]"%runtime)
	get_node("Groovetime").set_text("[b][i][color=gray]Groove time[/color][/i][b]\n\n[b]%d seconds[/b]"%groove)


func set_runtime(t):
	runtime = t
	update_trophies()

func set_groovetime(t):
	groove = t
	update_trophies()
