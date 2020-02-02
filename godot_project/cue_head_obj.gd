extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "head"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("TargetTimer").animate_timer(target_time-start_time)

func has_been_hit():
	if not hit:
		var parent = self.get_parent()
		var delta = abs(target_time - parent.current_playback_time)
		parent.score_hit(delta)
		hit = true
		get_node("head_cue/AnimationPlayer").play("explode")
	
