extends Spatial

var music_volume = 0
var inside_sfx = false

func squat():
	var player = get_node("MeshInstance/AnimationPlayer")
	player.play("squat")
	play_sfx("player_squat")
	
func stand():
	var player = get_node("MeshInstance/AnimationPlayer")
	player.play("stand")
	play_sfx("player_stand")

func jump():
	var player = get_node("MeshInstance/AnimationPlayer")
	player.play("stand")
	play_sfx("player_jump")

func pushup():
	var player = get_node("MeshInstance/AnimationPlayer")
	player.play("pushup")
	play_sfx("player_pushup")

func crunch():
	var player = get_node("MeshInstance/AnimationPlayer")
	player.play("crunch")
	play_sfx("player_crunch")


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
