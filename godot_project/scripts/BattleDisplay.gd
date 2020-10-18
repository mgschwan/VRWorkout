extends Spatial

onready var player_bar1 = $HealthBarLeft
onready var player_bar2 = $HealthBarRight

onready var player1 = $PlayerLeft
onready var player2 = $PlayerRight

var player1_score = 0
var player1_points = 0
var player1_max_health = 100
var player1_health = player1_max_health

var player2_score = 0
var player2_points = 0
var player2_max_health = 100
var player2_health = player2_max_health
var cpu_strength = 0.9 # 90% strength

func attack(by_player):
	if by_player == "left":
		player1.attack_01(false,false, player2.get_node("Armature/Skeleton/BoneAttachment").global_transform.origin)
	else:
		player2.attack_01(false,false, player1.get_node("Armature/Skeleton/BoneAttachment").global_transform.origin)

func defend(by_player):
	if by_player == "left":
		player1.defense_01(false,false)
	else:
		player2.defense_01(false,false)

func get_winner():
	var max_score = max(player1_score,player2_score)
	var min_score = min(player1_score,player2_score)

	var retVal = 1
	if player1_score > player2_score:
		retVal = -1
	if player1_score == player2_score:
		retVal = 0

	if retVal == 0:
		if player1_points != player2_points:
			if player1_points > player2_points:
				retVal = -1
			else:
				retVal = 1
				
	return retVal

func evaluate_exercise():
	self.attack("left")
	self.attack("right")

	var winner = get_winner()
	
	var percent_delta = 0
	var delta = abs (player1_score-player2_score)
	if max(player1_score,player2_score) > 0:
		percent_delta = delta / max(player1_score,player2_score)
		
	var attack_power = min(percent_delta * 10.0, 10.0)
	if winner == -1:
		print ("Player 1 scores. Hit: %s"%str(attack_power))
		player2_health -= attack_power
	elif winner == 1:
		print ("Player 2 scores. Hit: %s"%str(attack_power))	
		player1_health -= attack_power

	player1_score = 0
	player1_points = 0
	player2_score = 0
	player2_points = 0
	
	update_healthbars()
	
func update_healthbars():
	if player1_max_health > 0:
		set_level("left", player1_health/player1_max_health)
	if player2_max_health > 0:
		set_level("right", player2_health/player2_max_health)
	
func set_player_teams(left, right):
	if left == GameVariables.BattleTeam.BLUE:
		player1.set_appearance("blue")
	else:
		player1.set_appearance("red")

	if right == GameVariables.BattleTeam.BLUE:
		player2.set_appearance("blue")
	else:
		player2.set_appearance("red")


func hit_scored(hit_score, base_hit_score, points):
	player1_score += hit_score
	player1_points += points
	
	if GameVariables.battle_mode == GameVariables.BattleMode.CPU:
		if randf() < cpu_strength:
			player2_score += base_hit_score
			player2_points += 100

func _ready():
	pass
	
func set_level(player, level):
	if player == "left":
		player_bar1.set_level(level)
	elif player == "right":
		player_bar2.set_level(level)
