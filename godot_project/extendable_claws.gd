extends Spatial

var player
var state

enum ClawState {
	Retracted = 0,
	Extended= 1,
}

func _ready():
	player = get_node("AnimationPlayer")
	player.play("hidden")
	state = ClawState.Retracted
	
func extend():
	if state != ClawState.Extended:
		player.play("extend")
		state = ClawState.Extended


func retract():
	if state != ClawState.Retracted:
		player.play("retract")
		state = ClawState.Retracted

func is_extended():
	return state == ClawState.Extended
	
func is_retracted():
	return state == ClawState.Retracted
