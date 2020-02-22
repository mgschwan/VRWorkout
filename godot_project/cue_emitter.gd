extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_playback_time = 0
var points = 0
var hits = 0
var max_hits = 0
var point_indicator

# Called when the node enters the scene tree for the first time.
func _ready():
	point_indicator = get_node("PointIndicatorOrigin")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func score_negative_hits(hits):
	self.hits = max(self.hits-10, 0)
	max_hits += hits
	point_indicator.emit_text("-%d hits"%hits, "red")

func score_positive_hits(hits):
	self.hits += hits 
	max_hits += hits
	point_indicator.emit_text("+%d hits"%hits, "green")

func score_miss():
	point_indicator.emit_text("miss", "red")

func score_hit(delta):
	var multiplier = get_parent().run_point_multiplier
	var p = int(200 - min(delta*1000, 200))
	
	var hit_points = p * multiplier
	points += hit_points
	hits += 1
	point_indicator.emit_text("+%d"%hit_points,"green")
	get_parent().update_info(hits,max_hits,points) 
	return p
