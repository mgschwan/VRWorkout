extends Spatial

var node
var player


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


var first_dir = 1
var second_dir = 1
var first_idx = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	node = get_node("FirstLevel")
	player = get_node("FirstLevel/AnimationPlayer")
	
	
func set_next_beat(delta, level):
	var dir
	var tween
	var distance = 0
	if level == 0:
		if first_idx < 2:
			dir = 1
		else:
			dir = -1
		first_idx = (first_idx+1) % 4 
		tween = node.get_node("Tween")
		tween.interpolate_property(node,"translation:z", node.translation.z, distance*dir,delta,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
		tween.start()
		player.play("beat", -1, 4.0)
	elif level == 1:
		second_dir = -second_dir
		dir = second_dir
		distance = 3
		tween = node.get_node("Tween")
		tween.interpolate_property(node,"translation:x", node.translation.x,distance*dir,delta,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
		tween.start()



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
