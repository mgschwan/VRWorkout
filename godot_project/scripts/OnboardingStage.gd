extends Spatial

var cue_horiz = preload("res://cue_h_obj.tscn")
var cue_vert = preload("res://cue_v_obj.tscn")
var cue_head = preload("res://cue_head_obj.tscn")

signal onboarding_finished()

var current_state = 0

func _ready():
	show_state(0)
	GameVariables.vr_camera.blackout_screen(false)



var frame_limiter = 0
var wait_for_audio = false
var emitting_cues = false
func _process(delta):
	if current_state == 3 and not emitting_cues and not wait_for_audio:
		emit_cue()

	frame_limiter += 1
	if frame_limiter > 30:
		frame_limiter = 0
		if $AudioStreamPlayer.playing:
			var pos = $AudioStreamPlayer.get_playback_position()
			adjust_highlight(current_audio_slot, pos)

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
		$cue_emitter.set_move_tween(cue_node,Vector3(0,get_viewport().get_camera().translation.y,0), Vector3(0,get_viewport().get_camera().translation.y,10), 5)	

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
	elif state == 5:
		play_audio("slide6")
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
		elif current_cue_demonstration == 3:
			wait_for_audio = true
			play_audio("slide4d")
	emitting_cues = false
	
func _on_Audio_finished():
	wait_for_audio = false


var slide1 = preload("res://scripts/3rdparty/onboarding/audio/slide1.mp3")
var slide2 = preload("res://scripts/3rdparty/onboarding/audio/slide2.mp3")
var slide3 = preload("res://scripts/3rdparty/onboarding/audio/slide3.mp3")
var slide4 = preload("res://scripts/3rdparty/onboarding/audio/slide4a.mp3")
var slide4b = preload("res://scripts/3rdparty/onboarding/audio/slide4b.mp3")
var slide4c = preload("res://scripts/3rdparty/onboarding/audio/slide4c.mp3")
var slide4d = preload("res://audio/instruction_very_good.wav")
var slide5 = preload("res://scripts/3rdparty/onboarding/audio/slide5.mp3")
var slide6 = preload("res://scripts/3rdparty/onboarding/audio/slide6.mp3")


var current_audio_slot = ""
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
	elif value == "slide4d":
		audio = slide4d
	elif value == "slide5":
		audio = slide5
	elif value == "slide6":
		audio = slide6
		
	if audio:
		current_audio_slot = value
		$AudioStreamPlayer.stream = audio
		$AudioStreamPlayer.play()
					
func stop_audio():
	$AudioStreamPlayer.stop()
	wait_for_audio = false


var highlights = { "slide1": [[2.5, 100.0, Vector3(-0.401, 0, 0.148603)]
							],
					"slide2": [[2.0, 5.5, Vector3(0.023, 0, -0.2315)],
							 [6.0, 9.5, Vector3(0.023, 0, -0.05474)],
							 [10.0, 15.0, Vector3(0.023, 0, 0.1376)],
							 [15.1, 100.0, Vector3(-0.401, 0, 0.148603)]
							],
					"slide3": [[2.8, 8.0, Vector3(0.023, 0, -0.2315)],
							   [8.28, 11.8 , Vector3(0.023, 0, -0.014078)],
							 [11.7, 100.0, Vector3(-0.401, 0, 0.148603)]
							],
					"slide4": [[2.02, 100.0, Vector3(0.023, 0, -0.2315)]],
					"slide4b": [[0.1, 100.0, Vector3(0.023, 0, -0.05474)]],
					"slide4c": [[0.1, 100.0, Vector3(0.023, 0, 0.1376)]],
					"slide4d": [[0.0, 100.0, Vector3(-0.401, 0, 0.148603)]],
					"slide5": [[2.0, 3.75, Vector3(0.023, 0, -0.2315)],
							 [3.93, 8.0, Vector3(0.023, 0, -0.014078)],
							 [8.1, 100.0, Vector3(-0.401, 0, 0.148603)]
							],
					"slide6": [[6.7, 9.5, Vector3(0.023, 0, -0.2315)],
							 [9.7, 15.9, Vector3(0.023, 0, -0.014078)],
							 [16.0, 100.0, Vector3(-0.401, 0, 0.148603)]
							],

}

#Check if there is a highlightmarker for the current audio position
func adjust_highlight(slot, pos):
	var hlist = highlights.get(slot,[])
	var spatial_pos = null
	for h in hlist:
		if h[0] <= pos and pos <= h[1]:
			spatial_pos = h[2]
			break
	
	if spatial_pos != null:
		print ("Found marker: %s"%str(spatial_pos))
		$StaticBody/highlight.translation = spatial_pos
		$StaticBody/highlight.show()
	else:
		$StaticBody/highlight.hide()
		
