extends Control

signal content_changed()

func _on_content_changed():
	emit_signal("content_changed")
