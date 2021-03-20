extends Node2D

signal skybox_selected(value) 


func _on_Button1_pressed():
	emit_signal("skybox_selected","calm")


func _on_Button2_pressed():
	emit_signal("skybox_selected","angry")


func _on_Button3_pressed():
	emit_signal("skybox_selected","bright")
