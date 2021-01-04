extends Spatial

export(bool) var is_local = false
export(bool) var is_root = true
export(bool) var transform_parent = false
export var node_type = "player"
export var update_interval_ms = 100
export var prediction_interval_ms = 20

var remote_player_id = -1
var remote_node_id = -1
var multiplayer_room = null
var target_node = self
var last_update = 0

func _ready():
	if transform_parent:
		target_node = get_parent()

func _exit_tree():
	if multiplayer_room and target_node:
		if is_local:
			multiplayer_room.spatial_remove_message(target_node)

var last_local_pos = Vector3(0,0,0)
#TODO implement rotation interpolation as well var last_local_rot = Quat(0,0,0,1)
var last_local_ts = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Should this stuff be in the physics_process?
	if multiplayer_room and target_node:
		var now = OS.get_ticks_msec()
		
		if is_local:
			if now > last_local_ts + prediction_interval_ms:
				last_local_pos = target_node.translation
				last_local_ts = now
			if now > last_update + update_interval_ms:
				var delta_t = float(now - last_local_ts)/1000.0
				var movement_vector = Vector3(0,0,0)
				if delta_t > 0 and delta_t < 1.0:
					movement_vector = (target_node.translation-last_local_pos) / delta

				last_update = now
				if is_root:
					multiplayer_room.send_move_message(target_node, -1, node_type, movement_vector)
				else:
					multiplayer_room.send_move_message(target_node, target_node.get_parent().get_instance_id(), node_type, movement_vector)
		else:
			var node_pos = multiplayer_room.get_node_position(remote_player_id,remote_node_id)
			var pos = node_pos.get("pos", Vector3(0,0,0))
			var rot = node_pos.get("rot", Vector3(0,0,0))
			var movement = node_pos.get("movement", Vector3(0,0,0))
			var timestamp = node_pos.get("timestamp",0)
			var delta_t = clamp(float(now-timestamp)/1000.0,0.0,update_interval_ms/1000.0)
			
			target_node.translation.x = pos[0] + delta_t * movement[0]
			target_node.translation.y = pos[1] + delta_t * movement[1]
			target_node.translation.z = pos[2] + delta_t * movement[2]
			
			target_node.rotation.x = rot[0]
			target_node.rotation.y = rot[1]
			target_node.rotation.z = rot[2]
