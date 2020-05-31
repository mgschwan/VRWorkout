extends StaticBody

signal difficulty_selected(difficulty)


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_level():
	return get_parent().level_number
	
func get_difficulty_selector():
	if self.name == "Auto":
		return -1
	if self.name == "Medium":
		return 1
	if self.name == "Hard":
		return 2
	return 0
		

func touched_by_controller(obj, root):
	if not get_parent().get_parent().is_in_animation():
		print ("Difficulty touched")
		emit_signal("difficulty_selected",get_difficulty_selector())
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
