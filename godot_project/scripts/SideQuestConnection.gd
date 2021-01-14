extends Spatial

var sidequest

func _ready():
	sidequest = get_parent().get_parent().get_parent().get_node("SideQuestPanel")
	sidequest.connect("link_shortcode", self, "_on_link_shortcode")
	sidequest.connect("link_finished", self, "_on_link_finished")
	sidequest.connect("link_failed", self, "_on_link_failed")
	get_node("SideQuestPanel").print_info("To connect your SideQuest profile to the game push all 3 buttons below this panel and follow the instructions")

func disable_all_connect_switches():
		get_node("SideQuestPanel/ConnectSwitch").set_state(false)
		get_node("SideQuestPanel/ConnectSwitch2").set_state(false)
		get_node("SideQuestPanel/ConnectSwitch3").set_state(false)
	
func connect_sidequest():
	sidequest.link()
	
func evaluate_connect_switches():
	var switch1 = get_node("SideQuestPanel/ConnectSwitch").value
	var switch2 = get_node("SideQuestPanel/ConnectSwitch2").value
	var switch3 = get_node("SideQuestPanel/ConnectSwitch3").value

	if switch1 and switch2 and switch3:
		connect_sidequest()	

func _on_ConnectSwitch_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()

func _on_ConnectSwitch2_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()

func _on_ConnectSwitch3_toggled(value):
	evaluate_connect_switches()
	yield(get_tree().create_timer(1.0), "timeout")
	disable_all_connect_switches()


func _on_link_shortcode(code, link_url):
	get_node("SideQuestPanel").print_info("Open your browser and got to: \n\n    %s\n\nEnter the code: \n\n    %s\n\nand click to allow the linking."%[link_url, code])
	
func _on_link_finished():
	get_node("SideQuestPanel").print_info("Congratulations!\n\nYour SideQuest account has been linked successfully.")

func _on_link_failed():	
	get_node("SideQuestPanel").print_info("Linking did not work!\n\nThere was a problem linking your SideQuest account.")
