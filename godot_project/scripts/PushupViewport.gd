extends Viewport

onready var camera = $Camera

func _process(delta):
	if GameVariables.player_camera:
		$Camera.global_transform.origin = GameVariables.player_camera.global_transform.origin
