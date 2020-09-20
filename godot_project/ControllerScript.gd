extends ARVRController

var is_left = false

var tracking_lost = false

var collision_root = null
var model = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

# Called when the node enters the scene tree for the first time.
func _ready():
	collision_root = get_node("Area")
	model = get_node("Area/handle_ball")
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fixed_global_transform:
		get_node("Area").global_transform = saved_global_transform
	
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
	get_parent().get_parent().level.infolayer.print_info("Velocity %.2f"%velocity, "debug")
	return velocity


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
		main_area.scale = Vector3(0.05,0.05,0.05)
	else:
		main_area.scale = Vector3(0.1,0.1,0.1)



