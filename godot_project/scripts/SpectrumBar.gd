extends Spatial

var element_count= 10

var bar_elements = []

func _ready():
	var bar_element = get_node("BarElement")
	bar_elements.append(bar_element)
	for i in range(1, element_count):
		bar_elements.append(bar_element.duplicate())
		add_child(bar_elements[-1])
		bar_elements[-1].translation.z = -i*bar_elements[-1].scale.y*3


	set_energy(0)


func set_energy(value):
	var active_elements = int(clamp(value*element_count, 0 , element_count))
	var i = 0
	
	while i < active_elements and i < element_count:
		bar_elements[i].get_node("Active").show()
		i = i +1
	while i < element_count:
		bar_elements[i].get_node("Active").hide()
		i = i + 1
	
