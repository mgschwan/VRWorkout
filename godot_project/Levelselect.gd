extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("MainText").print_info("VRWorkout\nSelect song by touching a block\nBest played hands only - no controllers\nPosition yourself between the blue poles\nRun in place to get multipliers")
	get_node("BeastModeSelector").beast_mode = ProjectSettings.get("game/beast_mode")
	get_node("BeastModeSelector").update_switch()
	
func set_main_text(text):
	get_node("MainText").print_info(text)

func get_last_beat():
	return get_node("BPM").last_beat



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
