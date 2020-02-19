extends Spatial

var standard_material = load("res://boxman_standard_material.tres")
var angry_material = load("res://boxman_angry_material.tres")
var mesh_obj

enum BoxmanAnimations {
	Idle = 0,
	Idle_To_Situp = 1,
	Situps = 2,
	Jumping = 3,
	Stand_To_Plank = 4,
	Squat = 5,
	Stand_To_Squat = 6,
	Squat_To_Stand = 7,
	Situp_To_Idle = 8,
	Plank_To_Stand = 9,
	Plank = 10,
	Dying = 11,
	Run = 12,
	Dying_Middle = 13,

}

var animations
var current_animation = BoxmanAnimations.Idle
var continuous = false

var animation_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	animations = get_node("AnimationPlayer")
	mesh_obj = get_node("Armature/Skeleton/Cube001")	
	idle(true)
	
func clear_animation_queue():
	animation_queue.clear()

func play_current_animation(continuous=false):
	self.continuous = continuous
	if current_animation == BoxmanAnimations.Idle:
		animations.play("idle")
	elif current_animation == BoxmanAnimations.Idle_To_Situp:
		animations.play("idle_to_situp")
	elif current_animation == BoxmanAnimations.Situp_To_Idle:
		animations.play_backwards("idle_to_situp")
	elif current_animation == BoxmanAnimations.Situps:
		animations.play("situps")
	elif current_animation == BoxmanAnimations.Jumping:
		animations.play("jumping")
	elif current_animation == BoxmanAnimations.Stand_To_Plank:
		animations.play("stand_to_plank")
	elif current_animation == BoxmanAnimations.Plank_To_Stand:
		animations.play_backwards("stand_to_plank")
	elif current_animation == BoxmanAnimations.Squat:
		animations.play("squat")
	elif current_animation == BoxmanAnimations.Stand_To_Squat:
		animations.play("stand_to_squat")
	elif current_animation == BoxmanAnimations.Squat_To_Stand:
		animations.play("squat_to_stand")
	elif current_animation == BoxmanAnimations.Plank:
		animations.play("plank")
	elif current_animation == BoxmanAnimations.Dying:
		animations.play("dying_back")
	elif current_animation == BoxmanAnimations.Dying_Middle:
		animations.play("dying")
	elif current_animation == BoxmanAnimations.Run:
		animations.play("running")
		

func play_state(animation, continuous = false, enqueue = false):
	if enqueue:
		add_state(animation)
	else:
		current_animation = animation
		clear_animation_queue()
		play_current_animation(continuous)

func jump(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Jumping, continuous, enqueue)
	
func idle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Idle, continuous,  enqueue)

func idle_to_situp(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Idle_To_Situp,  continuous, enqueue)

func situp_to_idle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Situp_To_Idle, continuous,  enqueue)

func situps(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Situps, continuous,  enqueue)

func stand_to_plank(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Plank, continuous,  enqueue)

func plank_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Plank_To_Stand, continuous,  enqueue)

func squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat, continuous,  enqueue)
	
func stand_to_squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Squat, continuous,  enqueue)
	
func squat_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat_To_Stand, continuous,  enqueue)

func plank(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Plank, continuous,  enqueue)

func dying(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Dying, continuous,  enqueue)

func dying_middle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Dying_Middle, continuous,  enqueue)


func run(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Run, continuous,  enqueue)


func stop_animation():
	continuous = false
	animations.stop()

func to_stand(enqueue):
	if current_animation == BoxmanAnimations.Stand_To_Plank or current_animation == BoxmanAnimations.Plank:
		plank_to_stand(false,enqueue)
	elif current_animation == BoxmanAnimations.Jumping:
		idle(false, enqueue)
	elif current_animation == BoxmanAnimations.Squat:
		squat_to_stand(false, enqueue)
	elif current_animation == BoxmanAnimations.Situps:
		situp_to_idle(false, enqueue)
	else:
		idle(false, enqueue)

func add_state(state):
	animation_queue.append(state)

func switch_to_jumping():
	to_stand(true)
	add_state(BoxmanAnimations.Jumping)
	play_current_animation(true)

func switch_to_stand():
	to_stand(true)
	add_state(BoxmanAnimations.Idle)
	play_current_animation(true)

func switch_to_plank():
	to_stand(true)
	add_state(BoxmanAnimations.Stand_To_Plank)
	add_state(BoxmanAnimations.Plank)
	play_current_animation(true)

func switch_to_squat():
	to_stand(true)
	add_state(BoxmanAnimations.Stand_To_Squat)
	add_state(BoxmanAnimations.Squat)
	play_current_animation(true)
	
func switch_to_situps():
	to_stand(true)
	add_state(BoxmanAnimations.Idle_To_Situp)
	add_state(BoxmanAnimations.Situps)
	play_current_animation(true)
	

func _on_AnimationPlayer_animation_finished(anim_name):
	if len(animation_queue) > 0:
		current_animation = animation_queue.pop_front()
		play_current_animation(continuous)
	elif continuous:
		print ("Repeat animation")
		play_current_animation(continuous)

func kill(hitarea = "head"):
	if movement_tween:
		movement_tween.stop_all()
	if hitarea == "torso":
		dying_middle()
	else:
		dying()
	yield(get_tree().create_timer(2.0),"timeout")
	beast_reset()

var in_beast_mode = false
var beast_start_transformation
var movement_tween = null

func beast_reset():
	in_beast_mode = false
	mesh_obj.set_surface_material(0, standard_material)
	if movement_tween:
		movement_tween.queue_free()
	transform = beast_start_transformation
	to_stand(false)

func _on_beast_run_finished(obj, path):
	beast_reset()
	
func activate_beast(target, duration):
	if not in_beast_mode:
		in_beast_mode = true
		mesh_obj.set_surface_material(0, angry_material)
		beast_start_transformation = transform
		run(true)
		movement_tween = Tween.new()
		movement_tween.set_name("tween")
		add_child(movement_tween)
		look_at(target,Vector3(0,1,0))
		rotation.y = rotation.y + deg2rad(180)
		movement_tween.interpolate_property(self,"translation",self.translation,target,duration,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
		movement_tween.connect("tween_completed", self, "_on_beast_run_finished")
		movement_tween.start()		
	
	


