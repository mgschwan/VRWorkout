extends ARVRController

var hand_mode = false



var last_controller = [{"pos": Vector3(0,0,0), "ts": 0, "vector": Vector3(0,0,0)}]

var last_pos = [Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)]
var last_time = [0,0,0]

var last_steady_counter = 0
var candidate_steady_pos = Vector3(0,0,0)
var last_steady_pos = Vector3(0,0,0)
#When the tracker get's removed the position seems to be invalid during the on_tracker_removed
func get_past_position():
	return last_steady_pos

func _process(delta):
	if candidate_steady_pos.distance_to(self.translation) < 0.1:		
		candidate_steady_pos = (candidate_steady_pos + self.translation)/2.0
		last_steady_counter += 1
	else:
		candidate_steady_pos = self.translation
		last_steady_counter = 0
		
	if last_steady_counter > 40:
		last_steady_pos = candidate_steady_pos	
		last_steady_counter = 0		
		
	
	
	last_pos[2] = last_pos[1]
	last_pos[1] = last_pos[0]
	last_pos[0] = self.translation
	last_time[2] = last_time[1] 
	last_time[1] = last_time[0]
	last_time[0] = delta 


var hit_player

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_player = get_node("hit_player")

func _on_Area_body_entered(body):
	if body.has_method("has_been_hit"):
		if body.cue_type == "weight":
			var controller = self
			#var velocity = controller.get_hit_velocity()
			#print ("Velocity %.4f/%.2f"%[velocity,body.velocity_required])
			var p = body.has_been_hit()
			if body.emit_sound:
				body.emit_sound = false
				hit_player.play(0)
				controller.do_rumble( p > 0)
		else:
			#Ignore
			pass



func do_rumble(good = true):
	self.set_rumble(0.5)
	get_node("RumbleTimer").start()
	
func _on_RumbleTimer_timeout():
	self.set_rumble(0.0)




