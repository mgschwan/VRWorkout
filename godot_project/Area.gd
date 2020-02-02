extends Area

signal level_selected(num, diff)
signal exit_event()
var hit_player

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_player = get_node("hit_player")

func _on_Area_body_entered(body):
	if body.has_method("has_been_hit"):
		if body.cue_type == "hand":
			var controller = get_parent()
			var velocity = controller.get_hit_velocity()
			print ("Velocity %.4f"%velocity)
			if velocity > 1.25:
				var hand = "left"
				if controller.name == "right_controller":
					hand = "right"
				var p = body.has_been_hit(hand)
				if p >= 0:
					hit_player.play(0)
					controller.do_rumble( p > 0)
		else:
			# Ignore if the hand controller touched the head cue
			pass
	elif body.name == "exit_button":
		emit_signal("exit_event")
	elif body.has_method("beat"):
		print ("Beat hit")
		body.beat()
	elif body.has_method("touched_by_controller"):
		body.touched_by_controller(get_parent(), get_parent().get_parent().get_parent())
	else:	
		var name = body.name
		var level = -1
		var difficulty = 0
		if body.has_method("get_level"):
			level = body.get_level()
			if body.has_method("get_difficulty_selector"):
				difficulty = body.get_difficulty_selector()
				print ("Level selected %d %d"%[level,difficulty])
				emit_signal("level_selected", level, difficulty)
