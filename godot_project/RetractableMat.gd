extends Spatial

var is_open = false

func _ready():
	pass # Replace with function body.


func open_mat():
	if not is_open:
		get_node("AnimationPlayer").play("open",-1,2.0)
		is_open = true
		
func close_mat():
	if is_open:
		get_node("AnimationPlayer").play_backwards("open")
		is_open = false


