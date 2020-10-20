extends Area

var hit_player

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	hit_player = get_node("hit_player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AreaHead_body_entered(body):
	if body.has_method("has_been_hit") and body.cue_type == "head":
		body.has_been_hit()
		if body.emit_sound:
			body.emit_sound = false
			hit_player.play(0)
