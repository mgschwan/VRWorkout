extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var ingame_id = 0

var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "head"
var extended = false
var point_multiplier = 1.0
export var avoid = false

var emit_sound = true
var stars = 0


var hit_score = 1.0

func update_stars():
	$Stars.show()
	$Stars/star1.hide()
	$Stars/star2.hide()
	$Stars/star3.hide()

	if stars > 0:
		$Stars.show()
		$Stars/star1.show()
	if stars > 1:
		$Stars/star2.show()
	if stars > 2:
		$Stars/star3.show()

func hard_enough(value):
	return value >= stars

# Called when the node enters the scene tree for the first time.
func _ready():
	if extended:
		get_node("CollisionShapeExtended").show()
		get_node("CollisionShapeExtended").disabled = false
	else:
		get_node("CollisionShapeExtended").hide()
		get_node("CollisionShapeExtended").disabled = true

	update_stars()		
	get_node("head_cue/TargetTimer").animate_timer(target_time-start_time)

	

func has_been_hit():
	if not hit:
		get_node("tween").stop_all()
		var parent = self.get_parent()
		var delta = abs(target_time - parent.current_playback_time)
		parent.score_hit(delta, self)
		hit = true
		print ("Start sprinkling")
		get_node("CollisionShapeExtended").hide()
		get_node("CollisionShapeExtended").disabled = true
		get_node("sprinkle").emitting = true
		get_node("head_cue/AnimationPlayer").play("explode")

var opponent_hit = false
func hit_by_opponent():
	if not opponent_hit:
		opponent_hit = true
		get_node("sprinkle_opponent").emitting = true



func _on_AnimationPlayer_animation_finished(anim_name):
	get_node("sprinkle").emitting = false
	print ("Finish sprinkling")
	self.queue_free()
