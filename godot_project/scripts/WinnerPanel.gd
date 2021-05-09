extends Spatial

func set_winner(value):
	if value:
		$Viewport/you_win.show()
		$Viewport/you_lose.hide()
	else:
		$Viewport/you_win.hide()
		$Viewport/you_lose.show()
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
		
func set_points(points):
	$Viewport/Label.text = "%.1f points"%points
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE
