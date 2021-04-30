extends Spatial

export(Material) var bright_material
export(Material) var dark_material

var stage = "blue"
var blue_mat = preload("res://materials/blue_stage_grid.tres")
var red_mat = preload("res://materials/red_stage_grid.tres")

func _ready():
	set_color(stage)
	var stage = "dark"
	if ProjectSettings.has_setting("game/stage"):
		stage = ProjectSettings.get("game/stage")
	set_environment(stage)
	
func set_color(color):
	stage = color
	if color == "blue":
		get_node("Grid001").set_surface_material(0, blue_mat)
	else:
		get_node("Grid001").set_surface_material(0, red_mat)

func set_environment(value):
	if value == "bright":
		$Grid002.set_surface_material(0,bright_material)
	else:
		$Grid002.set_surface_material(0,dark_material)



