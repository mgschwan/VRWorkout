extends Spatial

var gu = GameUtilities.new()

func switch(value):
	if GameVariables.ar_mode:
		gu.activate_node(get_node("box3"))
		gu.deactivate_node(get_node("box1"))
		gu.deactivate_node(get_node("box2"))
	else:
		gu.deactivate_node(get_node("box3"))
		if value == "angry":
			gu.activate_node(get_node("box2"))
			gu.deactivate_node(get_node("box1"))
		else:
			gu.activate_node(get_node("box1"))
			gu.deactivate_node(get_node("box2"))
		

func _ready():
	switch("calm")
