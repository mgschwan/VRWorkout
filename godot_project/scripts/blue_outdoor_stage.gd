extends Spatial

var stage = "blue"
var blue_mat = preload("res://materials/blue_stage_grid.tres")
var red_mat = preload("res://materials/red_stage_grid.tres")

func _ready():
	set_color(stage)
	
func set_color(color):
	stage = color
	if color == "blue":
		get_node("Grid001").set_surface_material(0, blue_mat)
	else:
		get_node("Grid001").set_surface_material(0, red_mat)



