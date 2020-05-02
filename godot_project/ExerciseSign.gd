extends MeshInstance
export var current_sign = "stand"

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("AnimationPlayer").play(current_sign)

func play(anim):
	get_node("AnimationPlayer").play(anim)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
