extends Spatial

onready var level_bar = $Level


func _ready():
	pass


func set_level(value):
	level_bar.scale.x = clamp(value,0.0,1.0)
