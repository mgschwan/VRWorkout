extends StaticBody

export var target_area = "head"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var character_root

# Called when the node enters the scene tree for the first time.
func _ready():
	character_root = get_parent().get_parent().get_parent().get_parent()

func hit_by_claw():
	print ("hit by claw")
	character_root.kill(target_area)
