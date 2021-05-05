extends Control

signal onboarding_finished()
signal onboarding_state_changed(state)


func _on_Next_pressed():
	if $TabContainer.current_tab < $TabContainer.get_tab_count() -1:
		$TabContainer.current_tab = posmod($TabContainer.current_tab + 1, $TabContainer.get_tab_count())
		emit_signal("onboarding_state_changed", $TabContainer.current_tab)
	else:
		emit_signal("onboarding_finished")
		
func _on_SkipIntro_pressed():
	emit_signal("onboarding_finished")


func _on_Previous_pressed():
	$TabContainer.current_tab = posmod($TabContainer.current_tab - 1, $TabContainer.get_tab_count())
	emit_signal("onboarding_state_changed", $TabContainer.current_tab)
