extends StaticBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var ingame_id = 0

var velocity_required = 1.25

var hit = false
var emit_sound = true
var is_hold_cue = false
var hold_time = 1.0
var target_time = 0.0
var start_time = 0.0
var cue_type = "hand"
var hold_time_offset = 0.0
var point_multiplier = 1.0

var hit_score = 1.0

export(bool) var cue_left = true
var coupled_node = null 
var parent

var hold_start = 0
var holding = false

var dot_template = null

var hold_node 
var hold_ring_node 
var hold_ring_player 

# Called when the node enters the scene tree for the first time.
func _ready():
	hold_node = get_node("Circle/hold")
	hold_ring_node = get_node("Circle/hold_ring")
	hold_ring_player = hold_ring_node.get_node("AnimationPlayer")
	dot_template = get_node("dot")
	var target_timer = get_node("Circle/TargetTimer")
	if is_hold_cue:
		hold_node.hide()
		hold_ring_node.show()
		target_timer.hide()
	else:
		hold_node.hide()
		hold_ring_node.hide()
		target_timer.show()
		target_timer.animate_timer(target_time-start_time)
	parent = self.get_parent()


func create_path_dot():
	var node = MeshInstance.new()
	node.mesh = SphereMesh.new()
	node.mesh.radius = 0.02
	node.mesh.height = 0.04
	node.mesh.rings = 3
	node.mesh.radial_segments = 6
	return node


var path_calculated = false
func _process(delta):
	if not hit and is_hold_cue and holding:
		var now = OS.get_ticks_msec()
		var rd = now - hold_start
		if hold_time:
			var angle = 2*PI * rd/1000.0*hold_time
			hold_node.rotation.y = angle
		if 1000.0 * hold_time < now - hold_start:
			var hand = "right"
			if cue_left:
				hand = "left"
			has_been_hit(hand)
	
	
	if not path_calculated and coupled_node:
		var tw = get_node("tween")
		if tw and tw.is_active():
			#The tween of the coupled node may have a different start value
			#so we need to wait until tween of th coupled node is active
			var d = global_transform.origin - coupled_node.global_transform.origin
			for i in range(4):		
				var dot = dot_template.duplicate()
				dot.show()
				add_child(dot)
				dot.global_transform.origin = global_transform.origin-(i+1)*d/5.0 
			path_calculated = true
	elif coupled_node == null:
		path_calculated = true

#Returns the points the hit created or -1 if it was hit by the wrong hand
func has_been_hit(hand = "unknown"):
	var points = 0
	if not has_node(hand):
		points = -1
	elif not hit:
		get_node("tween").stop_all()
		var delta = abs(target_time - parent.current_playback_time)
		points = parent.score_hit(delta, self)
		hit = true
		get_node("sprinkle").emitting = true
		get_node("Circle/AnimationPlayer").play("explode")
		get_node("path").hide()
	return points

func begin_hold(hand = "unknown"):
	if has_node(hand):
		holding = true
		hold_start = OS.get_ticks_msec()+hold_time_offset
		hold_ring_player.play("ring",	-1 , 1/hold_time)
		

func end_hold(hand = "unknown"):
	if has_node(hand):
		holding = false
		hold_time_offset = OS.get_ticks_msec() - hold_start
		print ("Cue held for %f msec"%float(hold_time_offset))
		hold_ring_player.stop(false)


func activate_path_cue(target):
	coupled_node = target

func _on_AnimationPlayer_animation_finished(anim_name):
	get_node("sprinkle").emitting = false
	self.queue_free()
