extends Spatial


func _on_Node2D_skybox_selected(value):
	get_tree().current_scene.change_environment(value)
