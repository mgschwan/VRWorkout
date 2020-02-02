extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func animate_timer(duration):
	tween = Tween.new()
	var progress = get_node("progress")
	tween.interpolate_property(progress,"rotation",Vector3(0,0,0),Vector3(0,0,2*PI),duration,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	self.add_child(tween)
	tween.start()
	
#func update_progress(current, total):
#	var elapsed = 0
#	if total > 0:
#		elapsed = clamp(current/total,0.0, 1.0)
#	get_node("progress").rotation.z = 2*PI*elapsed
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
