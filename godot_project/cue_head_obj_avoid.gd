extends StaticBody

var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "head"


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
