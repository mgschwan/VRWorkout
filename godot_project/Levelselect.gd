extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	print ("Local addresses: %s"%str(IP.get_local_addresses()))
	
	
	get_node("MainText").print_info("VRWorkout\nSelect song by touching a block\nBest played hands only - no controllers\nPosition yourself between the blue poles\nRun in place to get multipliers\n\nTurn around for a tutorial")
	
	get_node("Tutorial").print_info("How to play\n- Hit the hand cues to the beat of the music\n- Head cues should only be touched no headbutts\n- Run in place to receive point multipliers!\nThe optimal time to hit the cues is when the\nrotating marker meets the static one")	
	
	get_node("BeastModeSelector").beast_mode = ProjectSettings.get("game/beast_mode")
	get_node("BeastModeSelector").update_switch()
	
	get_node("JumpSwitch").value = ProjectSettings.get("game/exercise/jump")
	get_node("JumpSwitch").update_switch()
	
	get_node("StandSwitch").value = ProjectSettings.get("game/exercise/stand")
	get_node("StandSwitch").update_switch()
	
	get_node("SquatSwitch").value = ProjectSettings.get("game/exercise/squat")
	get_node("SquatSwitch").update_switch()
	
	get_node("PushupSwitch").value = ProjectSettings.get("game/exercise/pushup")
	get_node("PushupSwitch").update_switch()

	get_node("CrunchSwitch").value = ProjectSettings.get("game/exercise/crunch")
	get_node("CrunchSwitch").update_switch()

	get_node("BurpeeSwitch").value = ProjectSettings.get("game/exercise/burpees")
	get_node("BurpeeSwitch").update_switch()


	
func set_main_text(text):
	get_node("MainText").print_info(text)

func get_last_beat():
	return get_node("BPM").last_beat



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_JumpSwitch_toggled(value):
	ProjectSettings.set("game/exercise/jump", value)
	
func _on_StandSwitch_toggled(value):
	ProjectSettings.set("game/exercise/stand", value)


func _on_CrunchSwitch_toggled(value):
	ProjectSettings.set("game/exercise/crunch", value)


func _on_SquatSwitch_toggled(value):
	ProjectSettings.set("game/exercise/squat", value)


func _on_PushupSwitch_toggled(value):
	ProjectSettings.set("game/exercise/pushup", value)


func _on_BurpeeSwitch_toggled(value):
	ProjectSettings.set("game/exercise/burpees", value)
