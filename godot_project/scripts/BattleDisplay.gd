extends Spatial

onready var player_bar1 = $HealthBarLeft
onready var player_bar2 = $HealthBarRight

onready var player1 = $PlayerLeft
onready var player2 = $PlayerRight

var health_total = 100

var defense_bonus = 0.1


var player1_score = 0
var player1_points = 0
var player1_max_health = health_total
var player1_health = player1_max_health
var player1_is_attack = true

var player2_score = 0
var player2_points = 0
var player2_max_health = health_total
var player2_health = player2_max_health
var player2_is_attack = true

var base_hit_damage = 10.0


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
	
	var adjusted_player1_score = player1_score
	var adjusted_player2_score = player2_score
	if not player1_is_attack:
		adjusted_player1_score = adjusted_player1_score * (1+defense_bonus)
	if not player2_is_attack:
		adjusted_player2_score = adjusted_player2_score * (1+defense_bonus)
	
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
	if player1_is_attack:
		self.attack("left")
	else:
		self.defend("left")
	
	if player2_is_attack:
		self.attack("right")
	else:
		self.defend("right")

	var winner = get_winner()
	
	var percent_delta = 0
	var delta = abs (player1_score-player2_score)
	if max(player1_score,player2_score) > 0:
		percent_delta = delta / max(player1_score,player2_score)
		
	var attack_power = min(percent_delta * base_hit_damage, base_hit_damage)
	if winner == -1:
		print ("Player 1 scores. Hit: %s"%str(attack_power))
		if player1_is_attack:
			player2_health -= attack_power
		else:
			print ("Player 2 defends")
	elif winner == 1:
		print ("Player 2 scores. Hit: %s"%str(attack_power))	
		if player2_is_attack:
			player1_health -= attack_power
		else:
			print ("Player 1 defends")
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

func cpu_hit():
	var cpu_strength = 0.6
	if GameVariables.difficulty > 0:
		cpu_strength = 0.75
	if GameVariables.difficulty > 1:
		cpu_strength  = 0.85
	
	var retVal = false
	if randf() < cpu_strength:
		#CPU scored a hit
		retVal = true

func cpu_select_strategy():
	var attack_desire = 0.6
	if GameVariables.difficulty > 0:
		attack_desire = 0.75
	if GameVariables.difficulty > 1:
		attack_desire  = 0.85
	
	player2_is_attack = false
	if randf() < attack_desire:
		#CPU scored a hit
		player2_is_attack = true
			
		

func hit_scored(hit_score, base_hit_score, points):
	player1_score += hit_score
	player1_points += points
	
	if GameVariables.battle_mode == GameVariables.BattleMode.CPU:
		if cpu_hit():
			player2_score += base_hit_score
			player2_points += 100
		cpu_select_strategy()

func setup_data(duration):
	if duration > 0:
	  base_hit_damage = clamp(health_total/(duration/20.0), 5, 20)

func _ready():
	pass
	
func set_level(player, level):
	if player == "left":
		player_bar1.set_level(level)
	elif player == "right":
		player_bar2.set_level(level)


func _on_Attack_activated():
	get_node("Attack").set_state(true)
	get_node("Defense").set_state(false)
	
	player1_is_attack = true

func _on_Defense_activated():
	get_node("Attack").set_state(false)
	get_node("Defense").set_state(true)



	player1_is_attack = false
