extends Spatial

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

}

var animations
var current_animation = BoxmanAnimations.Idle
var continuous = false

var animation_queue = []

# Called when the node enters the scene tree for the first time.
func _ready():
	animations = get_node("AnimationPlayer")	
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

func play_state(animation, continuous = false, enqueue = false):
	if enqueue:
		add_state(animation)
	else:
		current_animation = animation
		clear_animation_queue()
		play_current_animation(continuous)

func jump(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Jumping)
	
func idle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Idle)

func idle_to_situp(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Idle_To_Situp)

func situp_to_idle(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Situp_To_Idle)

func situps(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Situps)

func stand_to_plank(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Plank)

func plank_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Plank_To_Stand)

func squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat)
	
func stand_to_squat(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Stand_To_Squat)
	
func squat_to_stand(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Squat_To_Stand)

func plank(continuous = false, enqueue = false):
	play_state(BoxmanAnimations.Plank)

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
