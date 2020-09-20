extends Spatial

var last_beat = 0
var current_time = 0
export(float) var bpm = 1
var anim

var min_hr = 40
var max_hr = 250

var low = 0
var high = 0
var actual = 0

var hr_text = null

func _ready():
	anim = get_node("AnimationPlayer")
	hr_text = get_node("Viewport/CanvasLayer/CenterContainer/Label") 

func set_hr(hr_bpm):
	if not self.visible:
		self.show()
	bpm = hr_bpm
	hr_text.text = str(bpm)
	last_hr_update = current_time

func hide_coin():
	self.hide()

func update_markers():
	var delta = max(1.0,max_hr-min_hr)
	
	get_node("Circle/actual").rotation.y = 3*PI/2 - deg2rad(min_hr + 360 * actual/delta)
	get_node("Circle/low").rotation.y =  3*PI/2 - deg2rad(min_hr + 360 * low/delta)
	get_node("Circle/high").rotation.y = 3*PI/2 - deg2rad(min_hr + 360 * high/delta)

func set_marker(type, value):
	value = max(min_hr,min(max_hr,value))
	if type == "actual":
		actual = value
	elif type == "low":
		low = value
	elif type == "high":
		high = value
	update_markers()

var last_hr_update = 0
func _process(delta):
	current_time += delta
	if bpm > 0 and (last_beat + 60.0/bpm) < current_time:
		if not anim.is_playing():
			anim.play("beat",-1.0,3.0)
		last_beat = current_time	
	if current_time > last_hr_update + 5.0:
		hide_coin()
