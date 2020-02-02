extends StaticBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_level():
	return get_parent().level_number
	
func get_difficulty_selector():
	if self.name == "Medium":
		return 1
	if self.name == "Hard":
		return 2
	return 0
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
