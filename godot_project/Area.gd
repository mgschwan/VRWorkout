extends Area

var hit_player
var rumble_player

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_player = get_node("hit_player")
	rumble_player = get_node("rumble_audio")

func _on_Area_body_entered(body):
	print ("Touched %s"%body.name)
	
	if body.has_method("begin_hold") and body.is_hold_cue:
		if body.cue_type == "hand":
			var controller = get_parent()
			var hand = "right"
			if controller.is_left:
				hand = "left"
			body.begin_hold(hand)		
	elif body.has_method("has_been_hit"):
		if body.cue_type == "hand":
			var controller = get_parent()
			var velocity = controller.get_hit_velocity()
			print ("Velocity %.4f/%.2f"%[velocity,body.velocity_required])
			if velocity > body.velocity_required:
				var hand = "right"
				if controller.is_left:
					hand = "left"
				var p = body.has_been_hit(hand)
				if body.emit_sound and body.cue_left == (hand == "left"):
					body.emit_sound = false
					hit_player.play(0)
					
					#TODO: For Woojer vest but deactivated for now because it sound terrible 
					#rumble_player.play(0)
					
					controller.do_rumble( p > 0)
		else:
			# Ignore if the hand controller touched the head cue
			pass
	elif body.has_method("beat"):
		print ("Beat hit")
		body.beat()
	elif body.has_method("touched_by_controller"):
		body.touched_by_controller(get_parent(), get_parent().get_parent().get_parent())



func _on_Area_body_exited(body):
	if body.has_method("end_hold") and body.is_hold_cue:
		if body.cue_type == "hand":
			var controller = get_parent()
			var hand = "right"
			if controller.is_left:
				hand = "left"
			body.end_hold(hand)		
			
	elif body.has_method("released_by_controller"):
		body.released_by_controller(get_parent(), get_parent().get_parent().get_parent())
