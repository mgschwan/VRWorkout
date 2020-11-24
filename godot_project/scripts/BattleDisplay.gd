extends Spatial

var gu = GameUtilities.new()



onready var player_bar1 = $HealthBarLeft
onready var player_bar2 = $HealthBarRight

onready var player_energybar1 = $EnergyBarLeft
onready var player_energybar2 = $EnergyBarRight

onready var player1 = $PlayerLeft
onready var player2 = $PlayerRight

var health_total = 100.0
var energy_total = 100.0
var defense_bonus = 0.2
var min_attack_percent = 0.33
var min_defend_percent = 0.33
var cpu_player = load("res://scripts/CPUPlayer.gd").new()

var current_round_max_score = 0

var base_hit_damage = 10.0

signal player_won(player)

func player_by_name(player):
	if player == "left":
		return player1
	else:
		return player2

func can_attack(player_obj):
	if (player_obj.player_energy / player_obj.player_max_energy) >= min_attack_percent:
		return true
	return false

func can_defend(player_obj):
	if (player_obj.player_energy / player_obj.player_max_energy) >= min_defend_percent:
		return true
	return false



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

func evaluate_attack(player):
	var attacker = player_by_name(player)
	var defender
	if player == "left":
		defender = player_by_name("right")
	else:
		defender = player_by_name("left")


	var attack_energy = (100.0 * attacker.player_energy/attacker.player_max_energy) / 10.0
	
	if defender.attack_mode == "defense":
		attack_energy = max(attack_energy - (100.0 * defender.player_energy/defender.player_max_energy)/10.0,0)
		defender.player_energy = max(0, defender.player_energy - attacker.player_energy)
	
	defender.player_health = clamp(defender.player_health-attack_energy, 0, defender.player_max_health)
	attacker.player_energy = 0
	
	print ("Attack: %f Defender health: %f"%[attack_energy, defender.player_health])
	
	if player1.player_health == 0:
		player1.kill("head", false)
		emit_signal("player_won","right")
	elif player2.player_health == 0:
		player2.kill("head", false)
		emit_signal("player_won","left")
	
	update_healthbars()
	
func update_healthbars():
	if player1.player_max_health > 0:
		set_level("left", player1.player_health/player1.player_max_health)
	if player1.player_max_energy > 0:
		set_energy("left", player1.player_energy/player1.player_max_energy)	
	if player2.player_max_health > 0:
		set_level("right", player2.player_health/player2.player_max_health)
	if player2.player_max_energy > 0:
		set_energy("right", player2.player_energy/player2.player_max_energy)
	
	
func set_player_teams(left, right):
	if left == GameVariables.BattleTeam.BLUE:
		player1.set_appearance("blue")
	else:
		player1.set_appearance("red")

	if right == GameVariables.BattleTeam.BLUE:
		player2.set_appearance("blue")
	else:
		player2.set_appearance("red")

func cpu_select_strategy():		
	if player2.attack_mode == "idle":
		if player1.attack_mode == "attack":
			if can_defend(player2):
				var defense_desire = 0.3
				if GameVariables.difficulty > 0:
					defense_desire = 0.5
				if GameVariables.difficulty > 1:
					defense_desire  = 0.75
				if randf() < defense_desire:
					player2.player_is_attack = false
					player2.defense_01(false,false,4.0)
				
				
		if player2.attack_mode == "idle":
			if can_attack(player2):
				var attack_desire = 0.3
				if GameVariables.difficulty > 0:
					attack_desire = 0.5
				if GameVariables.difficulty > 1:
					attack_desire  = 0.75
				if randf() < attack_desire:
					player2.player_is_attack = true
					player2.charge_attack(2.0)


var current_exercise = GameVariables.CueState.STAND	
func set_exercise(exercise):
	current_exercise = exercise

var active_cues = Array()
func queue_cue(cue):
	gu.insert_cue_sorted(cue.target_time, cue, active_cues)

func hit_scored_opponent (obj):
	if cpu_player.cpu_hit(current_exercise):
		if obj and obj.has_method("hit_by_opponent"):
			obj.hit_by_opponent()
		#This formula should be calculated at a central location
		var hitp = int(200 - randf()*199)
		player2.player_points += hitp

		player2.player_energy = clamp(player2.player_energy + hitp/30.0, 0, 100)
	update_healthbars()

func hit_scored(hit_score, base_hit_score, points, obj):
	player1.player_score += hit_score
	player1.player_points += points
	
	current_round_max_score += base_hit_score
	
	if GameVariables.battle_mode == GameVariables.BattleMode.CPU:
		player2.player_score += base_hit_score
	
	player1.player_energy = clamp(player1.player_energy + points/30.0, 0, 100)
	update_healthbars()

func setup_data(duration):
	if duration > 0:
	  base_hit_damage = clamp(health_total/(duration/20.0), 5, 20)


var last_eval = 0
var eval_interval = 500
func _process(delta):	
	if GameVariables.battle_mode != GameVariables.BattleMode.NO:	
		
		while len(active_cues) > 0 and active_cues[0][0] < cue_emitter.current_playback_time:
			var cue = active_cues.pop_front()
			hit_scored_opponent(cue[1])
		
		var now = OS.get_ticks_msec()
		if last_eval + eval_interval < now:
			last_eval = now 
			cpu_select_strategy()
	
var enemy_images = {
	"easy": "res://assets/enemy_easy.jpg",
	"medium": "res://assets/enemy_medium.jpg",
	"hard": "res://assets/enemy_hard.jpg",
}
	
var cue_emitter
func _ready():
	cue_emitter = get_parent().get_node("cue_emitter")
	
	get_node("GestureInterface").attach(GameVariables.vr_camera)
	
	if GameVariables.battle_mode != GameVariables.BattleMode.NO:
		cpu_player.character = GameVariables.battle_enemy
		get_node("EnemyPanel").set_image(enemy_images.get(cpu_player.character))
		
		
		player1.player_score = 0
		player1.player_points = 0
		player1.player_max_health = health_total
		player1.player_max_energy = energy_total
		player1.player_health = health_total
		player1.player_energy = 0
		player1.player_is_attack = true
	
		player2.player_score = 0
		player2.player_points = 0
		player2.player_max_health = health_total
		player2.player_max_energy = energy_total
		player2.player_health = health_total
		player2.player_energy = 0
		player2.player_is_attack = true
		
		update_healthbars()
	
func set_level(player, level):
	if player == "left":
		player_bar1.set_level(level)
	elif player == "right":
		player_bar2.set_level(level)

func set_energy(player, level):
	if player == "left":
		player_energybar1.set_level(level)
	elif player == "right":
		player_energybar2.set_level(level)

func _on_Attack_activated():
	if can_attack(player1):
		player1.player_is_attack = true
		player1.charge_attack(2.0)

func _on_Defense_activated():
	if can_defend(player1):
		player1.player_is_attack = false
		player1.defense_01(false,false,4.0)

func _on_Attack_charge_complete(player):
	attack(player)

func _on_Attack_complete(player):
	evaluate_attack(player)


