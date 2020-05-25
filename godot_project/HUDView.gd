extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_warning_level(level):
	if level == 0:
		get_node("Level1").hide()
		get_node("Level2").hide()
		get_node("Level3").hide()
		get_node("Level4").hide()
	elif level == 1:
		get_node("Level1").show()
		get_node("Level2").hide()
		get_node("Level3").hide()
		get_node("Level4").hide()
	elif level == 2:
		get_node("Level1").show()
		get_node("Level2").show()
		get_node("Level3").hide()
		get_node("Level4").hide()
	elif level == 3:
		get_node("Level1").show()
		get_node("Level2").show()
		get_node("Level3").show()
		get_node("Level4").hide()
	elif level == 4:
		get_node("Level1").show()
		get_node("Level2").show()
		get_node("Level3").show()
		get_node("Level4").show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
