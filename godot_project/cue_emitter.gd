extends Spatial

var gu = GameUtilities.new()

var current_playback_time = 0
var points = 0
var hits = 0
var max_hits = 0
var point_indicator = null

var hud_enabled = false

var run_point_multiplier = 1.0


signal show_hud()
signal hide_hud()
signal streak_changed(count)
signal hit_scored(hit_score, base_score, points, obj)
signal update_info(hits,max_hits,points)

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_node("PointIndicatorOrigin"):
		point_indicator = get_node("PointIndicatorOrigin")
	hud_enabled = ProjectSettings.get("game/hud_enabled")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func get_cue_by_id(ingame_id):
	var retVal = null
	for c in self.get_children():
		if "ingame_id" in c and c.ingame_id == ingame_id:
			retVal = c
			break
	return retVal

var current_points = 0
var current_hits = 0
var current_max_hits = 0
var streak_length = 0

func reset_current_points():
	current_points = 0
	current_hits = 0
	current_max_hits = 0
	streak_length = 0

func get_current_streak():
	return streak_length

func get_hit_score():
	return current_points
	
func get_success_rate():
	var retVal = 100.0
	if current_max_hits > 0:
		retVal = 100.0 * float(current_hits)/float(current_max_hits)

func update_statistics_element(obj, hit, points):
	current_points += points
	var hit_score = 1
	var actual_hit_score = 0
	if obj:
		hit_score = obj.hit_score
	if hit:
		actual_hit_score = hit_score
		streak_length += 1
	else:
		streak_length = 0
		
	current_hits +=  actual_hit_score
	current_max_hits += hit_score

	if obj:
		if GameVariables.level_statistics_data.has(obj.ingame_id):
			GameVariables.level_statistics_data[obj.ingame_id]["h"] = hit
			GameVariables.level_statistics_data[obj.ingame_id]["p"] = points

	emit_signal("streak_changed", get_current_streak())
	emit_signal("hit_scored", actual_hit_score, hit_score, points, obj)


func update_hits(hit_score, is_hit):
	self.max_hits += max(0,hit_score)
	if is_hit:
		self.hits += hit_score
		self.hits = max(self.hits, 0)

func score_negative_hits(hits):
	GameVariables.vr_camera.tint_screen(0.2)
	update_hits(-hits, true)
	if point_indicator:
		point_indicator.emit_text("-%d hits"%hits, "red")

func score_positive_hits(hits):
	update_hits(hits, true)
	if point_indicator:
		point_indicator.emit_text("+%d hits"%hits, "green")

func score_miss(obj):
	if point_indicator:
		point_indicator.emit_text("miss", "red")
	update_hits(obj.hit_score, false)
	update_statistics_element(obj, false, 0)

#If a cue that should not have been hit has been avoided
func score_avoided(obj):
	update_statistics_element(obj, false, 0)

func score_points(hit_score, hit_points, obj=null):
	update_statistics_element(obj, hit_score, hit_points)

	if hit_score > 0 or hit_points > 0:
		points += hit_points
		update_hits(1,true)
		if point_indicator:
			point_indicator.emit_text("+%d"%hit_points,"green")
		emit_signal("update_info",hits,max_hits,points) 
	return hit_points

func score_hit(delta, obj = null):
	var p = 0
	if obj.has_method("hard_enough") and not obj.hard_enough(gu.hardness_level()):
		score_negative_hits(1)
	else:	
		var multiplier = run_point_multiplier
		if obj and "point_multiplier" in obj:
			multiplier = multiplier * obj.point_multiplier
			
		p = max (10, int(200 - min(delta*1000, 200)))
		
		var hit_points = p * multiplier
		points += hit_points
		update_hits(obj.hit_score, true)
		var pts_color = "green"
		if multiplier > 1.0:
			pts_color = "white"
		if point_indicator:
			point_indicator.emit_text("+%d"%hit_points,pts_color)

		update_statistics_element(obj, true, hit_points)

		emit_signal("update_info",hits,max_hits,points) 
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
		
func set_move_tween(cue_node, start_pos, end_pos, actual_flytime, curved_direction = 0):
	var move_modifier = Tween.new()
	move_modifier.set_name("tween")
	cue_node.set_meta("move_tween", move_modifier)
	cue_node.add_child(move_modifier)

	var x = start_pos[0]
	var y = start_pos[1]
	
	cue_node.translation.x = start_pos[0]
	cue_node.translation.y = start_pos[1]
	move_modifier.interpolate_property(cue_node,"translation:z",start_pos[2],end_pos[2],actual_flytime,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)

	if streak_length > 5 and cue_node.has_method("show_trail"):
		var vel = clamp(float(streak_length - 5) / 20.0, 0, 0.5)
		print ("Streak velocity = %f"%vel)
		cue_node.show_trail(true, vel) #
	
	if curved_direction != 0:
		if cue_node.has_method("show_trail"):
			cue_node.show_trail(true)
		var additional_move_modifier = Tween.new()
		cue_node.add_child(additional_move_modifier)
		if "rotate_to_player" in cue_node:
			cue_node.rotate_to_player = true

		if cue_node.translation.y > GameVariables.player_height:
			additional_move_modifier.interpolate_property(cue_node,"translation:y",2.0,y-1.0,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
			additional_move_modifier.interpolate_property(cue_node,"translation:y",y-1.0,y,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,actual_flytime*0.5)
		else:
			additional_move_modifier.interpolate_property(cue_node,"translation:y",0,GameVariables.player_height+1.5,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
			additional_move_modifier.interpolate_property(cue_node,"translation:y",GameVariables.player_height+1.5,y,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,actual_flytime*0.5)
		
	
		additional_move_modifier.interpolate_property(cue_node,"translation:x",x,x+curved_direction,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,0)
		additional_move_modifier.interpolate_property(cue_node,"translation:x",x+curved_direction, 0,actual_flytime*0.5,Tween.TRANS_LINEAR,Tween.EASE_IN_OUT,actual_flytime*0.5)
		additional_move_modifier.start()
		
	move_modifier.connect("tween_completed",self,"_on_tween_completed")
	move_modifier.start()
		
		
func _on_tween_completed(obj,path):
	if obj.has_method("should_be_avoided") and obj.should_be_avoided():
		score_avoided(obj)
	else:
		score_miss(obj)
	obj.queue_free()
