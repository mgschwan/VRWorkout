extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_playback_time = 0
var points = 0
var hits = 0
var max_hits = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func score_hit(delta):
	var multiplier = get_parent().run_point_multiplier
	var p = int(200 - min(delta*1000, 200))
	points += p * multiplier
	hits += 1
	get_parent().update_info(hits,max_hits,points) 
	return p
