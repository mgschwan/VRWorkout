extends Spatial

var last_beat = 0
var current_time = 0
export(float) var bpm = 1
var anim

var hr_text = null

func _ready():
	anim = get_node("AnimationPlayer")
	hr_text = get_node("Viewport/CanvasLayer/CenterContainer/Label") 

func set_hr(hr_bpm):
	if not self.visible:
		self.show()
	bpm = hr_bpm
	hr_text.text = str(bpm)

func _process(delta):
	current_time += delta
	if bpm > 0 and last_beat + 60/bpm < current_time:
		#next beat
		if not anim.is_playing():
			anim.play("beat",-1.0,0.2)
		last_beat = current_time	
