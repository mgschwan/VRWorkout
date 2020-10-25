extends Spatial

var gu = GameUtilities.new()

onready var level_bar = $Level
export(bool) var is_energy = false

func _ready():
	if is_energy:
		gu.activate_node(get_node("Level/EnergyBar"))
		gu.deactivate_node(get_node("Level/HealthBar"))
	else:
		gu.deactivate_node(get_node("Level/EnergyBar"))
		gu.activate_node(get_node("Level/HealthBar"))
		

func set_level(value):
	level_bar.scale.x = clamp(value,0.0,1.0)
