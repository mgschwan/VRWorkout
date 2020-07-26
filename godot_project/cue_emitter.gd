extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var current_playback_time = 0
var points = 0
var hits = 0
var max_hits = 0
var point_indicator

var hud_enabled = false

signal show_hud()
signal hide_hud()


# Called when the node enters the scene tree for the first time.
func _ready():
	point_indicator = get_node("PointIndicatorOrigin")
	hud_enabled = ProjectSettings.get("game/hud_enabled")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_statistics_element(obj, hit, points):
	if GameVariables.level_statistics_data.has(obj.ingame_id):
		GameVariables.level_statistics_data[obj.ingame_id]["hit"] = hit
		GameVariables.level_statistics_data[obj.ingame_id]["points"] = points

func score_negative_hits(hits):
	get_viewport().get_camera().tint_screen(0.2)
	self.hits = max(self.hits-hits, 0)
	max_hits += hits
	point_indicator.emit_text("-%d hits"%hits, "red")

func score_positive_hits(hits):
	self.hits += hits 
	max_hits += hits
	point_indicator.emit_text("+%d hits"%hits, "green")

func score_miss(obj):
	point_indicator.emit_text("miss", "red")
	update_statistics_element(obj, false, 0)

#If a cue that should not have been hit has been avoided
func score_avoided(obj):
	update_statistics_element(obj, false, 0)

func score_points(hit_points):
	if hit_points > 0:
		points += hit_points
		hits += 1
		max_hits += 1
		point_indicator.emit_text("+%d"%hit_points,"green")
		get_parent().update_info(hits,max_hits,points) 
	return hit_points

func score_hit(delta, obj = null):
	var multiplier = get_parent().run_point_multiplier
	var p = int(200 - min(delta*1000, 200))
	
	var hit_points = p * multiplier
	points += hit_points
	hits += 1
	point_indicator.emit_text("+%d"%hit_points,"green")

	update_statistics_element(obj, true, hit_points)

	get_parent().update_info(hits,max_hits,points) 
	return p


func get_closest_cue(pos, type, left = true):
	var nodes = self.get_children()
	var mindist = 1000
	var selected_node = null
	
	for n in nodes:
		var cue_type = n.get("cue_type")
		var is_left = n.get("cue_left")
		if cue_type == "hand" and not n.hit:
			if left == is_left:
				var d = pos.distance_to(n.global_transform.origin)
				if d < mindist:
					selected_node = n
					mindist = d
	return selected_node
		
func _on_VisibilityNotifier_camera_entered(camera):
	if hud_enabled:
		emit_signal("hide_hud")

func _on_VisibilityNotifier_camera_exited(camera):
	if hud_enabled:
		emit_signal("show_hud")
