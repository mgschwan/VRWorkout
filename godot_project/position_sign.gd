extends Spatial


signal state_change_completed

var music_volume = 0
var inside_sfx = false

func squat():
	get_node("ExerciseSign").play("squat")
	play_sfx("player_squat")
	
func stand():
	get_node("ExerciseSign").play("stand")
	play_sfx("player_stand")

func jump():
	get_node("ExerciseSign").play("jump")
	play_sfx("player_jump")

func pushup():
	get_node("ExerciseSign").play("pushup")
	play_sfx("player_pushup")

func crunch():
	get_node("ExerciseSign").play("crunch")
	play_sfx("player_crunch")

func burpee():
	get_node("ExerciseSign").play("burpee")
	play_sfx("player_burpee")

func sprint():
	get_node("ExerciseSign").play("sprint")
	play_sfx("player_sprint")

func parcour():
	get_node("ExerciseSign").play("parcour")
	play_sfx("player_parcour")

func weights():
	get_node("ExerciseSign").play("weights")
	play_sfx("player_weights")


func start_sign(start, end, duration):
	var move_modifier = Tween.new()
	self.add_child(move_modifier)
	var t = self.translation	
	self.translation = Vector3(start.x, t.y, start.z)
	move_modifier.interpolate_property(self,"translation",Vector3(start.x, t.y, start.z) ,Vector3(t.x,t.y,end.z),duration,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	move_modifier.connect("tween_completed",self,"_on_tween_completed")
	move_modifier.start()
	self.show()

func _on_tween_completed(obj, path):
	print ("Hide")
	play_sfx("player_now")
	obj.hide()
	emit_signal("state_change_completed")


func play_sfx(name):
	if not inside_sfx:
		inside_sfx = true
		music_volume = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))
		print ("Master volume %.2f"%music_volume)
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), -6)
	get_node(name).play()

func _on_sfx_finished():
	if inside_sfx:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), music_volume)
		print ("Music returned to normal")
		music_volume = 0
		inside_sfx = false
