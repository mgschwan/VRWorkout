extends Control

signal content_changed()

func _on_NextButton_pressed():
	$TabContainer.current_tab = posmod($TabContainer.current_tab + 1, $TabContainer.get_tab_count())


func _on_PreviousButton_pressed():
	$TabContainer.current_tab = posmod($TabContainer.current_tab - 1, $TabContainer.get_tab_count())


func _on_TabContainer_tab_changed(tab):
	emit_signal("content_changed")
