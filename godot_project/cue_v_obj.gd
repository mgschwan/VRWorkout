extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var hit = false
var target_time = 0.0
var start_time = 0.0
var cue_type = "hand"
var coupled_node = null 
var parent

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = self.get_parent()
	get_node("TargetTimer").animate_timer(target_time-start_time)
	pass # Replace with function body.

var path_calculated = false
func _process(delta):
	if not path_calculated and coupled_node:
		var n = get_node("path")
		n.look_at(coupled_node.global_transform.origin,Vector3(0,1,0))
		n.get_node("cone").scale.z = (n.global_transform.origin - coupled_node.global_transform.origin).length()
		path_calculated = true

#Returns the points the hit created or -1 if it was hit by the wrong hand
func has_been_hit(hand = "unknown"):
	var points = 0
	if not has_node(hand):
		points = -1
	elif not hit:
		get_node("tween").stop_all()
		var delta = abs(target_time - parent.current_playback_time)
		points = parent.score_hit(delta)
		hit = true
		get_node("sprinkle").emitting = true
		get_node("Circle/AnimationPlayer").play("explode")
		get_node("path").hide()
	return points

func activate_path_cue(target):
	coupled_node = target
	var n = get_node("path")
	n.show()

func _on_AnimationPlayer_animation_finished(anim_name):
	get_node("sprinkle").emitting = false
	self.queue_free()
