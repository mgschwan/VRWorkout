extends Control



func _on_NextButton_pressed():
	$TabContainer.current_tab = posmod($TabContainer.current_tab + 1, $TabContainer.get_tab_count())


func _on_PreviousButton_pressed():
	$TabContainer.current_tab = posmod($TabContainer.current_tab - 1, $TabContainer.get_tab_count())
