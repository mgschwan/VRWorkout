extends Spatial

var gu = GameUtilities.new()

func switch(value):
	if value == "angry":
		gu.activate_node(get_node("box2"))
		gu.deactivate_node(get_node("box1"))
	else:
		gu.activate_node(get_node("box1"))
		gu.deactivate_node(get_node("box2"))
		

func _ready():
	switch("calm")
