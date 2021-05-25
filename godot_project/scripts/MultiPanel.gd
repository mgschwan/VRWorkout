extends Control


signal activate_feature(feature, active)
signal content_changed()

func _on_content_changed():
	emit_signal("content_changed")


func _on_activate_feature(feature, active):
	emit_signal("activate_feature", feature, active)
