extends Node


var network_server
var network_peer = null

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	network_server = TCP_Server.new()
#	network_server.listen(9444)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	if network_server.is_connection_available():
#		network_peer = network_server.take_connection()
#	if network_peer != null and network_peer.is_connected_to_host() and network_peer.get_available_bytes() >= 28:
#			var element = network_peer.get_32()
#			var x = network_peer.get_double()
#			var y = network_peer.get_double()
#			var z = network_peer.get_double()
#			print ("Received data %d (%f,%f,%f)"%[element,x,y,z])
