extends StaticBody

var player_height_stat = []
var height = 1.8
#According to Wikipedia an average person is about 7 1/2 heads tall.
#The eyes are approximately halfway down the head
#So the headset is at 7 heads height and the total height is 7 1/2
var eye_body_factor = 1.0714285714285714

var cam

func _ready():
	cam = GameVariables.vr_camera
	for i in range(200):
		player_height_stat.append(0)

var iterations = 0
func _process(delta):
	player_height_stat[ clamp(int(100*cam.translation.y),0,len(player_height_stat)-1) ] += 1
	var v = 0
	
	iterations = (iterations + 1) % 20
	if iterations == 0:
		for h in range(len(player_height_stat)):
			if player_height_stat[h] > v:
				v = player_height_stat[h]
				height = h/100.0
		self.translation.y = height
		height = height * eye_body_factor
		ProjectSettings.set("game/player_height", height)
		get_node("HeightIndicator/TextElement").print_info("Height: %.2f\nCan you read it?"%height)

func touched_by_controller(obj,root):
	for i in range(len(player_height_stat)):
		player_height_stat[i] = 0
		
