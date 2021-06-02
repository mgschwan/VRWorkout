extends Control


signal activate_feature(feature, active)
signal content_changed()

func _ready():
	if GameVariables.game_result.get("time", 0) > 0:
		#If the player is returning from an exercise show the stats
		#instead of the news
		$TabContainer.current_tab = 2


func _on_content_changed():
	emit_signal("content_changed")


func _on_activate_feature(feature, active):
	emit_signal("activate_feature", feature, active)
