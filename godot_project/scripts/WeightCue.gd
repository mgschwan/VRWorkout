extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ingame_id = 0

var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "weight"
var point_multiplier = 1.0
export var avoid = false

var emit_sound = true
var stars = 0

var hit_score = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func has_been_hit():
	var score = 0
	if not hit:
		get_node("tween").stop_all()
		var parent = self.get_parent()
		var delta = abs(target_time - parent.current_playback_time)
		score = parent.score_hit(delta, self)
		hit = true
		get_node("Model/AnimationPlayer").play("explode")
	return score

var opponent_hit = false
func hit_by_opponent():
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()

