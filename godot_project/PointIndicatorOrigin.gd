extends Spatial

var point_indicator = preload("res://PointIndicatorSprite.tscn")
var duration = 0.8

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_point_indicator_finished(obj,path):
	obj.queue_free()

func emit_text(text, color = "white"):
	var pi = point_indicator.instance()
	pi.default_text = text
	pi.default_color_name = color
	
	var movement_tween = Tween.new()
	pi.add_child(movement_tween)	
	movement_tween.interpolate_property(pi,"translation",pi.translation,pi.translation+Vector3(1.5*randf()-1,0.8,0),duration+randf()*0.2,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	movement_tween.connect("tween_completed", self, "_on_point_indicator_finished")
	add_child(pi)
	movement_tween.start()		

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
