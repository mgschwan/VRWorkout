extends Spatial

var cue_horiz = preload("res://cue_h_obj.tscn")
var cue_vert = preload("res://cue_v_obj.tscn")
var cue_head = preload("res://cue_head_obj.tscn")

signal onboarding_finished()

var current_state = 0

func _ready():
	show_state(0)

var wait_for_audio = false
var emitting_cues = false
func _process(delta):
	if current_state == 3 and not emitting_cues and not wait_for_audio:
		emit_cue()

var current_cue_demonstration = 0
func emit_cue():
	var cue_node = null

	if current_cue_demonstration == 0:
		cue_node = cue_horiz.instance()
	elif current_cue_demonstration == 1:
		cue_node = cue_vert.instance()
	elif current_cue_demonstration == 2:
		cue_node = cue_head.instance()
	
	if cue_node:
		emitting_cues = true
		$cue_emitter.add_child(cue_node)
		$cue_emitter.set_move_tween(cue_node,Vector3(0,GameVariables.player_height,0), Vector3(0,GameVariables.player_height,10), 5)	

func _on_Onboarding_onboarding_finished():
	emit_signal("onboarding_finished")

func show_state(state):
	stop_audio()
	current_state = state
	if state == 0:
		play_audio("slide1")
	elif state == 1:
		play_audio("slide2")
	elif state == 2:
		play_audio("slide3")
	elif state == 3:
		wait_for_audio = true
		current_cue_demonstration = 0
		play_audio("slide4")
		$MainStage/Poles.show()
	elif state == 4:
		play_audio("slide5")
	else:
		$MainStage/Poles.hide()


func _on_Onboarding_onboarding_state_changed(state):
	show_state(state)

func _on_cue_emitter_hit_scored(hit_score, base_score, points, obj):
	if hit_score > 0:
		current_cue_demonstration += 1
		if current_cue_demonstration == 1:
			wait_for_audio = true
			play_audio("slide4b")
		elif current_cue_demonstration == 2:
			wait_for_audio = true
			play_audio("slide4c")
		emitting_cues = false
	
func _on_Audio_finished():
	wait_for_audio = false


var slide1 = preload("res://scripts/3rdparty/onboarding/audio/slide1.mp3")
var slide2 = preload("res://scripts/3rdparty/onboarding/audio/slide2.mp3")
var slide3 = preload("res://scripts/3rdparty/onboarding/audio/slide3.mp3")
var slide4 = preload("res://scripts/3rdparty/onboarding/audio/slide4a.mp3")
var slide4b = preload("res://scripts/3rdparty/onboarding/audio/slide4b.mp3")
var slide4c = preload("res://scripts/3rdparty/onboarding/audio/slide4c.mp3")
var slide5 = preload("res://scripts/3rdparty/onboarding/audio/slide5.mp3")


func play_audio(value):
	var audio = null
	if value == "slide1":
		audio = slide1
	elif value == "slide2":
		audio = slide2
	elif value == "slide3":
		audio = slide3
	elif value == "slide4":
		audio = slide4
	elif value == "slide4b":
		audio = slide4b
	elif value == "slide4c":
		audio = slide4c
	elif value == "slide5":
		audio = slide5
		
	if audio:
		$AudioStreamPlayer.stream = audio
		$AudioStreamPlayer.play()
			
		
		
func stop_audio():
	$AudioStreamPlayer.stop()
	wait_for_audio = false
