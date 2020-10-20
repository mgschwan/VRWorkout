extends StaticBody

var ingame_id = 0

var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "head"
var point_multiplier = 1.0
var hit_score = 0

var emit_sound = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass	
	
func has_been_hit():
	if not hit:
		var parent = self.get_parent()
		parent.score_negative_hits(10)
		hit = true
		get_node("CollisionShape").hide()
		get_node("CollisionShape").disabled = true
		
func should_be_avoided():
	return true
