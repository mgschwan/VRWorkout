extends StaticBody

var gu = GameUtilities.new()

export(bool) var is_attack = true

signal activated()

func _ready():
	if is_attack:
		gu.activate_node(get_node("Signs/AttackShield"))
		gu.deactivate_node(get_node("Signs/DefenseShield"))
	else:
		gu.activate_node(get_node("Signs/DefenseShield"))
		gu.deactivate_node(get_node("Signs/AttackShield"))
	set_state(true)


func set_state(active):
	if active:
		get_node("Signs").scale = Vector3(1.0,1.0,1.0)
	else:
		get_node("Signs").scale = Vector3(0.5,0.5,0.5)


func touched_by_controller(parent,root):
	emit_signal("activated")
