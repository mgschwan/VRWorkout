extends StaticBody

signal touched
var gu = GameUtilities.new()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func touched_by_controller(obj, root):
	if gu.double_tap_debounce(self):
		emit_signal("touched")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
