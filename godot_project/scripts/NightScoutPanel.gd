extends Spatial


var frame_throttle = 0
func _process(delta):
	frame_throttle += 1
	if frame_throttle > 100:
		frame_throttle = 0
		$Viewport/NightScoutDisplay.update_data()
		$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
