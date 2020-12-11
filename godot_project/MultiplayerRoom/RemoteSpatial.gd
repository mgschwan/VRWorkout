extends Spatial

export(bool) var is_local = false
export(bool) var is_root = true
export(bool) var transform_parent = false
export var node_type = "player"

var remote_player_id = -1
var remote_node_id = -1
var multiplayer_room = null
var target_node = self

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	if transform_parent:
		target_node = get_parent()

func _exit_tree():
	if multiplayer_room and target_node:
		if is_local:
			multiplayer_room.spatial_remove_message(target_node)
			

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if multiplayer_room and target_node:
		if is_local:
			if is_root:
				multiplayer_room.send_move_message(target_node, -1, node_type)
			else:
				multiplayer_room.send_move_message(target_node, target_node.get_parent().get_instance_id(), node_type)
		else:
			var node_pos = multiplayer_room.get_node_position(remote_player_id,remote_node_id)
			var pos = node_pos.get("pos")
			var rot = node_pos.get("rot")
			
			target_node.translation.x = pos[0]
			target_node.translation.y = pos[1]
			target_node.translation.z = pos[2]
			
			target_node.rotation.x = rot[0]
			target_node.rotation.y = rot[1]
			target_node.rotation.z = rot[2]
