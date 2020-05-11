extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var streams = { "stand": "res://assets/stand_sample.webm",
			    "jump": "res://assets/jump_sample.webm",
				"squat": "res://assets/squat_sample.webm",
				"crunch": "res://assets/crunch_sample.webm",
				"burpee": "res://assets/burpee_sample.webm",
				"pushup": "res://assets/pushup_sample.webm"
				}


# Called when the node enters the scene tree for the first time.
func _ready():
	print ("Videowall is ready")

func play(stream_name):
	var player = get_node("Viewport/Control/VideoPlayer")
	stop()
		
	var stream = VideoStreamWebm.new()
	if streams.has(stream_name):
		stream.set_file(streams[stream_name])
		player.stream = stream
		player.play()
	
func stop():
	var player = get_node("Viewport/Control/VideoPlayer")
	if player.is_playing():
		player.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_VisibilityNotifier_camera_exited(camera):
	print ("Videowall stop")
	stop()
