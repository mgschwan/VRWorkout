extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_difficulty(pos):
	#var delta = self.translation.distance_to(pos)
	var delta = pos.y
	var difficulty = 0
	if delta < 1.25:
		difficulty = 2
	elif delta < 1.5:
		difficulty = 1
	return difficulty
