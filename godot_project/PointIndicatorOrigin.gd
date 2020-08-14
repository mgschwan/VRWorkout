extends Spatial

var point_indicator = preload("res://PointIndicatorSprite.tscn")
var duration = 0.8

var spread = 2.0
var current_x = 0.0


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
	
	current_x = current_x + 1.23
	if current_x > spread:
		current_x -= spread
	
	var movement_tween = Tween.new()
	var scale_tween = Tween.new()
	pi.translation.x = current_x - spread/2.0
	pi.add_child(movement_tween)	
	pi.add_child(scale_tween)
	var runtime = duration+randf()*0.2
	movement_tween.interpolate_property(pi,"translation",pi.translation,pi.translation+Vector3((randf()-0.5)/4.0,0.8,0),runtime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	movement_tween.connect("tween_completed", self, "_on_point_indicator_finished")
	scale_tween.interpolate_property(pi,"scale", pi.scale, pi.scale*Vector3(0.33,0.33,0.33),runtime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
	add_child(pi)
	movement_tween.start()		
	scale_tween.start()

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
