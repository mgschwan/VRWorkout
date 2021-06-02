extends Spatial

var target_rot = Basis.IDENTITY

func update_widget():
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE


func set_player_name(value):
	$Viewport/Name.text = value
	update_widget()
	
func set_points(value):
	$Viewport/Points.text = "%.1f"%value
	update_widget()

func set_rank(value):
	$Viewport/Rank.text = "%d"%value
	update_widget()


	

func _process(delta):
	#$Info.global_transform.basis = target_rot
	var vec = $Info.global_transform.origin-GameVariables.vr_camera.global_transform.origin
	$Info.global_transform.basis = Basis(Vector3(0,atan2(vec.x,vec.z),0))
	var dist = vec.length()*0.8
	$Info.scale = Vector3(dist,dist,dist)

func _ready():
	target_rot = $Info.global_transform.basis
	
	update_widget()
	
