extends StaticBody

var beats = 0
var bpm = 140
var last_beat = 0


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var player
# Called when the node enters the scene tree for the first time.
func _ready():
	bpm = ProjectSettings.get("game/bpm")
	last_beat = OS.get_ticks_msec()
	update_text()
	player = get_node("AudioStreamPlayer")


func update_text():
	get_node("bpm_text").print_info("Hit to set bpm\nfor Freeplay\nBeats: %d / BPM: %d"%[beats,int(bpm)])

#If two beat call are more than 100msec apart then the beat is counted and
#the average BPM is calculated
func beat():
	var now = OS.get_ticks_msec()
	if last_beat > 0:
		var delta = now - last_beat
		if delta > 100:
			var new_bpm = (60000.0 / delta)
			bpm = bpm * 0.8 + 0.2 * new_bpm
			beats += 1
			last_beat = now
			player.play()
			ProjectSettings.set("game/bpm",bpm)
	else:
		player.play()
		last_beat = now
	update_text()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
