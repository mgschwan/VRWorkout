extends ARVRController

var is_left = false

var tracking_lost = false

var collision_root = null
var model = null

var hand_mode = false



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var gu = GameUtilities.new()


var last_controller = [{"pos": Vector3(0,0,0), "ts": 0, "vector": Vector3(0,0,0)}]

var last_pos = [Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)]
var last_time = [0,0,0]

var fixed_global_transform = false
var saved_global_transform = null

func fix_global_transform(fix):
	fixed_global_transform = false
	if fix:
		get_node("CenterMarker").show()
		fixed_global_transform = fix
		saved_global_transform = get_node("Area").global_transform
	else:
		get_node("CenterMarker").hide()




func set_hand_mode(hand_tracking):
	if hand_tracking:
		pass
		#get_node("Area/hand_model").set_hand_active(true)
		#gu.disconnect_all_connections(get_node("Area"),"body_entered")
		#gu.disconnect_all_connections(get_node("Area"),"body_exited")
		#gu.deactivate_node(get_node("Area/CollisionShape"))
		#gu.deactivate_node(get_node("Area/handle_ball"))
	else:
		pass
		#get_node("Area/hand_model").set_hand_active(false)
		#gu.disconnect_all_connections(get_node("Area/hand_model"),"body_entered")
		#gu.disconnect_all_connections(get_node("Area/hand_model"),"body_exited")
		#gu.activate_node(get_node("Area/CollisionShape"))
		#gu.activate_node(get_node("Area/handle_ball"))


# Called when the node enters the scene tree for the first time.
func _ready():
	set_hand_mode(hand_mode)

	collision_root = get_node("Area")
	model = get_node("Area/CollisionShape/handle_ball")
				
	if ProjectSettings.get("game/is_oculusquest"):
		get_node("Area/hand_model").hand_tracking = true

func update_bone_orientations(orientations, confidence):
	get_node("Area/hand_model").update_bone_orientations(orientations, confidence)

func is_fist():
	return get_node("Area/hand_model").is_fist()

func set_beast_mode(enabled):
	if enabled:
		get_node("Area/hand_model").beast_mode = true
	else:
		get_node("Area/hand_model").beast_mode = false


var distance_travelled = 0
var distance_vert_travelled = 0
var distance_horiz_travelled = 0
var time_elapsed = 0
var energy_calc_last_pos = Vector3(0,0,0)

func _physics_process(delta):
	distance_travelled += (self.translation.distance_to(energy_calc_last_pos))
	
	var vert_pos = Vector3(0,self.translation.y,0)
	var vert_last_pos = Vector3(0,energy_calc_last_pos.y,0)
	distance_vert_travelled += (vert_pos.distance_to(vert_last_pos))
	
	var horiz_pos = Vector3(self.translation.x,0,self.translation.z)
	var horiz_last_pos = Vector3(energy_calc_last_pos.x,0,energy_calc_last_pos.z)
	distance_horiz_travelled += (horiz_pos.distance_to(horiz_last_pos))

	
	time_elapsed += delta
	energy_calc_last_pos = self.translation
	if time_elapsed > 1.0:
		var meters_per_sec = distance_travelled/time_elapsed
		var meters_per_sec_horiz = distance_horiz_travelled/time_elapsed
		var meters_per_sec_vert = distance_vert_travelled/time_elapsed
		gu.update_current_controller_energy(meters_per_sec, meters_per_sec_vert, meters_per_sec_horiz, self.translation)
		distance_travelled = 0
		distance_vert_travelled = 0
		distance_horiz_travelled = 0
		time_elapsed = 0


var last_steady_counter = 0
var candidate_steady_pos = Vector3(0,0,0)
var last_steady_pos = Vector3(0,0,0)
#When the tracker get's removed the position seems to be invalid during the on_tracker_removed
func get_past_position():
	return last_steady_pos

var update_helper = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update_helper += delta
	if update_helper > 0.5:
		update_helper = 0
		
		if is_left:
			if GameVariables.hr_active:
				model.set_info("HR %d"%(GameVariables.current_hr))
			else:
				model.set_info("")
		else:
			model.set_info(gu.get_wall_time_str())
				
		if hand_mode:
			var source = get_node("Area/hand_model").get_ball_attachment()
			var source_root = get_node("Area/hand_model").get_root()
			var target = get_node("Area/CollisionShape")
			var scale = target.scale
			target.global_transform.origin = source.global_transform.origin
			target.global_transform.basis = source_root.global_transform.basis
			
			target.scale = scale


			
	if fixed_global_transform:
		get_node("Area").global_transform = saved_global_transform
		
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

func get_hit_velocity():
	var distance = self.translation.distance_to(last_pos[0])+ \
					last_pos[0].distance_to(last_pos[1])+ \
					last_pos[1].distance_to(last_pos[2])
		
	var timedelta = max(0.001, last_time[2])
	var velocity = distance/timedelta
	return velocity

func get_touch_object():
	#If we add different touch shapes that would have to be return here
	return model


func do_rumble(good = true):
	if good:
		get_node("Area/good_hit").show()
	else:
		get_node("Area/bad_hit").show()
	self.set_rumble(0.5)
	get_node("RumbleTimer").start()
	
	
func _on_RumbleTimer_timeout():
	get_node("Area/good_hit").hide()
	get_node("Area/bad_hit").hide()
	self.set_rumble(0.0)


func set_visible(value):
	if value:
		self.show()
	else:
		self.hide()
		
#Resize the collision area to make menu selection easier
func set_detail_select(value):
	var main_area = get_node("Area/CollisionShape")
	if value:
		print ("Set detail mode")
		get_node("Area/CollisionShape").shape.radius = 0.5
		#main_area.scale = Vector3(0.05,0.05,0.05)
	else:
		get_node("Area/CollisionShape").shape.radius = 1.0
		#main_area.scale = Vector3(0.1,0.1,0.1)




func show_hand(value):
	if value:
		get_node("Area/hand_model").show_hands()
	else:
		get_node("Area/hand_model").hide_hands()

func _on_Area_body_exited(area):
	pass # Replace with function body.
