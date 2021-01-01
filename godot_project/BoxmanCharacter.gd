extends Spatial

signal beast_attack_successful
signal beast_killed
signal charge_complete
signal attack_complete
signal defense_complete

var standard_material = load("res://materials/tron_blue_material.tres")
var angry_material = load("res://materials/tron_red_material.tres")
var mesh_obj

var active = true 

var animation_speed = 1.8



##################################
# Battle variables
##################################
var player_score
var player_points
var player_max_health
var player_max_energy
var player_health
var player_energy
var player_is_attack
var attack_mode = "idle"
##################################


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
	Attack_01 = 14,
	Defense_01 = 15,
	Burpee = 16,
	Stand_To_Burpee = 17,
	Burpee_To_Stand = 18,
}

var animations
var current_animation = BoxmanAnimations.Idle
var continuous = false

var animation_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("EnergyBall").set_as_toplevel(true)
	animations = get_node("AnimationPlayer")
	animations.playback_speed = animation_speed
	for anim in animations.get_animation_list():
		animations.get_animation(anim).loop = false
	mesh_obj = get_node("Armature/Skeleton/Mesh_0")	
	set_appearance("standard")
	idle(true)
	
func clear_animation_queue():
	animation_queue.clear()

func play_current_animation(continuous=false):
	self.continuous = continuous
	animations.stop()

	if current_animation == BoxmanAnimations.Idle:
		animations.play("idle-loop")
	elif current_animation == BoxmanAnimations.Idle_To_Situp:
		animations.play("idle_to_situp-loop")
	elif current_animation == BoxmanAnimations.Situp_To_Idle:
		animations.play("situp_to_idle-loop")
	elif current_animation == BoxmanAnimations.Situps:
		animations.play("situps-loop")
	elif current_animation == BoxmanAnimations.Jumping:
		animations.play("jumping-loop")
	elif current_animation == BoxmanAnimations.Stand_To_Plank:
		animations.play("stand_to_plank-loop")
	elif current_animation == BoxmanAnimations.Plank_To_Stand:
		animations.play_backwards("stand_to_plank-loop")
	elif current_animation == BoxmanAnimations.Squat:
		animations.play("squat-loop")
	elif current_animation == BoxmanAnimations.Stand_To_Squat:
		animations.play("stand_to_squat-loop")
	elif current_animation == BoxmanAnimations.Squat_To_Stand:
		animations.play("squat_to_stand-loop")
	elif current_animation == BoxmanAnimations.Plank:
		animations.play("plank-loop")
	elif current_animation == BoxmanAnimations.Dying:
		animations.play("dying_back-loop")
	elif current_animation == BoxmanAnimations.Dying_Middle:
		animations.play("dying-loop")
	elif current_animation == BoxmanAnimations.Run:
		animations.play("running-loop",-1, 0.75)
	elif current_animation == BoxmanAnimations.Attack_01:
		animations.play("attack_01-loop")
	elif current_animation == BoxmanAnimations.Defense_01:
		animations.play("defense_01-loop")
	elif current_animation == BoxmanAnimations.Burpee:
		animations.play("burpee-loop", -1, 0.9)
	elif current_animation == BoxmanAnimations.Stand_To_Burpee:
		animations.play("idle_to_burpee-loop")
	elif current_animation == BoxmanAnimations.Burpee_To_Stand:
		animations.play("burpee_to_idle-loop")

func play_state(animation, continuous = false, enqueue = false):
	if enqueue:
		add_state(animation)
	else:
		animations.stop()
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

func burpee_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Burpee_To_Stand, continuous,  enqueue)

func squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat, continuous,  enqueue)
	
func stand_to_squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Squat, continuous,  enqueue)
	
func squat_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat_To_Stand, continuous,  enqueue)

func squat_to_burpee(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Burpee, continuous,  enqueue)

func plank(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Plank, continuous,  enqueue)

func burpee(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Burpee, continuous,  enqueue)

func dying(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Dying, continuous,  enqueue)

func dying_middle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Dying_Middle, continuous,  enqueue)


func attack_01(continuous = false, enqueue = false, target = Vector3(0,0,0)):
	play_state(BoxmanAnimations.Attack_01, continuous,  enqueue)
	yield(get_tree().create_timer(0.5),"timeout")
	energy_ball_tween = "attack"
	get_node("EnergyBall").show()
	get_node("EnergyBall/Tween").interpolate_property(get_node("EnergyBall"),"translation", get_node("Armature/Skeleton/HandAttachment").global_transform.origin, target,0.4,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT, 0)
	get_node("EnergyBall/Tween").start()

var energy_ball_tween = ""

func _on_Tween_Energyball_completed():
	if energy_ball_tween == "attack":
		attack_mode="idle"
		get_node("EnergyBall").hide()
		emit_signal("attack_complete")
		play_state(BoxmanAnimations.Idle, true,  false)
	elif energy_ball_tween == "charge":
		emit_signal("charge_complete")
	energy_ball_tween = ""

var energy_ball_scale = 26.8
func charge_attack(duration):
	if attack_mode == "idle":
		attack_mode = "attack"
		var ball = get_node("EnergyBall")
		ball.translation = get_node("Armature/EnergyBase").global_transform.origin
		ball.scale = Vector3(0,0,0)
		ball.show() 
		energy_ball_tween = "charge"
		get_node("EnergyBall/Tween").interpolate_property(ball,"scale",Vector3(0,0,0),Vector3(energy_ball_scale,energy_ball_scale,energy_ball_scale),duration,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
		get_node("EnergyBall/Tween").start()
		

func defense_01(continuous = false, enqueue = false, duration = 2.0):
	if attack_mode == "idle":
		attack_mode = "defense"
		play_state(BoxmanAnimations.Defense_01, continuous,  enqueue)
		get_node("Armature/Skeleton/HandAttachment/EnergyShield").show()	
		yield(get_tree().create_timer(duration-0.5),"timeout")
		get_node("Armature/Skeleton/HandAttachment/EnergyShield").hide()	
		play_state(BoxmanAnimations.Idle, continuous,  enqueue)
		emit_signal("defense_complete")
		attack_mode="idle"

	
	
func run(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Run, continuous,  enqueue)


func stop_animation():
	continuous = false
	animations.stop()

func to_stand(enqueue):
	if current_animation == BoxmanAnimations.Stand_To_Plank or current_animation == BoxmanAnimations.Plank:
		plank_to_stand(false,enqueue)
	if current_animation == BoxmanAnimations.Stand_To_Burpee or current_animation == BoxmanAnimations.Burpee:
		burpee_to_stand(false,enqueue)
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
	
func switch_to_run():
	to_stand(true)
	add_state(BoxmanAnimations.Run)
	play_current_animation(true)

func switch_to_plank():
	to_stand(true)
	add_state(BoxmanAnimations.Stand_To_Plank)
	add_state(BoxmanAnimations.Plank)
	play_current_animation(true)

func switch_to_burpee():
	to_stand(true)
	add_state(BoxmanAnimations.Stand_To_Burpee)
	add_state(BoxmanAnimations.Burpee)
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
		play_current_animation(continuous)

func kill(hitarea = "head", respawn = true):
	if active:
		animations.stop()
		active = false
		if movement_tween:
			movement_tween.stop_all()
		if hitarea == "torso":
			dying_middle()
		else:
			dying()
		if respawn:	
			yield(get_tree().create_timer(2.0),"timeout")
			beast_reset()
			emit_signal("beast_killed")

var in_beast_mode = false
var beast_start_transformation
var movement_tween = null

func beast_reset():
	mesh_obj.set_surface_material(0, standard_material)
	if movement_tween:
		movement_tween.queue_free()
	transform = beast_start_transformation
	to_stand(false)
	in_beast_mode = false
	active = true

func _on_beast_run_finished(obj, path):
	if active:
		active = false
		#The beast has reached the target
		beast_reset()
		emit_signal("beast_attack_successful")

func set_appearance(value):
	if value == "red" or value == "angry":
		mesh_obj.set_surface_material(0, angry_material)
	else:
		mesh_obj.set_surface_material(0, standard_material)

func activate_beast(target, duration):
	if not in_beast_mode:
		in_beast_mode = true
		set_appearance("angry")
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
	
	



