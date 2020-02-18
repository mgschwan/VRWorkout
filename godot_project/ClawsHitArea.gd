extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func has_claws():
	return true


func _on_Area_body_entered(body):
	if body.has_method("hit_by_claw"):
		if get_parent().get_parent().is_extended():
			body.hit_by_claw()
