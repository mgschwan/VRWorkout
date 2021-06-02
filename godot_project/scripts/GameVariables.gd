extends Node


################## Warning, this has to be set to false in production builds
#############################################################################

var demo_mode = false
var hands_visible = false

#############################################################################

var vr_camera = null
var hit_player = null

#############################################################################
############################ Activated features #############################
var FEATURE_MULTIPLAYER = true

#Deactivate certain features to meet Oculus Store requirements
var FEATURE_STORE_COMPATIBILITY = false 

var FEATURE_FOVEATED_RENDERING = true


#############################################################################
######### Plugins should put their data into the Dictionary #################

var plugin_data = Dictionary()

#############################################################################



var app_name = "VRWorkout"
var api_version = 1
var player_name = "Player"
var vr_mode = true
var ar_mode = false

var multiplayer_server = ProjectSettings.get("application/config/room_server")
var multiplayer_api = null

var player_camera = null

var player_height = 1.8

var player_exercise_state = CueState.STAND

var detail_selection_mode = true
var trackers = null
var difficulty = 0
var override_beatmap = false
var device_id = ""
var auto_difficulty = false
var current_song = ""
var current_challenge = null
var current_hr = 0
var hr_active = false

var current_headset_energy = 0.0
var current_controller_energy = 0.0
var controller_energy_factor = 0.2
var headset_energy_factor = 1.0

var energy_level_low = 1.0
var energy_level_medium = 2.0
var energy_level_high = 3.0
var energy_level_max = 4.5

var exercise_duration_avg = 20.0


var stats = {
	"total_points": 0,
	"last_points": 0,
	"total_played": 0,
	"last_played": 0,
	"last_vrw_score": 0
}
	

#var stats_total_points = 0
#var stats_last_points = 0
#var total_played = 0
#var last_played = 0
#var vrw_score = 0




var tracker_config_database = Dictionary()

var config_file_location = "user://settings.json"
var achievement_file_location = "user://achievements.json"

var game_result = Dictionary()
var challenge_slots = Dictionary()
#This is the ghost data the player plays against
var input_level_statistics_data = Dictionary()

var current_ingame_id = 0
func get_next_ingame_id():
	current_ingame_id += 1
	return current_ingame_id
	
func reset_ingame_id():
	current_ingame_id = 0

enum BattleTeam {
	BLUE = 0,
	RED = 1,	
};

enum BattleMode {
	NO = 0,
	CPU = 1,
	# NOT IMPLEMENTED # STORED = 2,	
};

enum GameMode {
	STANDARD = 0,
	EXERCISE_SET = 1,
	STORED = 2,
};


var achievement_checks = Array()

var game_mode = GameMode.STANDARD
var battle_team = BattleTeam.BLUE
var battle_mode = BattleMode.NO
var battle_enemy = "easy"
var battle_interval = 5.0
var selected_game_slot = -1
var cue_list = Array()

enum CueState {
	STAND = 0,
	SQUAT = 1,
	PUSHUP = 2,
	CRUNCH = 3,
	JUMP = 4,
	BURPEE = 5,
	SPRINT = 6,
	YOGA = 7,
	PARCOUR = 8,	
	WEIGHTS = 9,
};

enum CueSelector {
	HEAD = 0,
	HAND = 1,	
};
	
enum PushupState {
	REGULAR = 0,
	LEFT_HAND = 1,
	RIGHT_HAND = 2,
	LEFT_SIDEPLANK = 3,
	RIGHT_SIDEPLANK = 4,
	LEFT_HAND_HOLD = 5,
	RIGHT_HAND_HOLD = 6,
};	

enum CrunchState {
	HEAD = 0,
	HAND = 1,
	MEDIUM_HOLD = 2,
};	


	
enum SquatState {
	HEAD = 0,
	LEFT_HAND = 1,
	RIGHT_HAND = 2,
	DOUBLE_SWING = 3,
	CROSS_CUT = 4,
};	


enum StandState {
	REGULAR = 0,
	DOUBLE_SWING = 1,
	WINDMILL_TOE = 2,
	PARCOUR = 3,
	HOLD_CUE = 4,
};	


var predefined_exercises = {
	"High pyramid": [
		["stand",10],["squat",10],["jump",10],["sprint",10],
		["stand",20],["squat",20],["jump",20],["sprint",20],
		["stand",30],["squat",30],["jump",30],["sprint",30],
		["stand",20],["squat",20],["jump",20],["sprint",20],
		["stand",10],["squat",10],["jump",10],["sprint",10],
		],
	"Low pyramid": [
		["crunch",10],["pushup",10],["squat",10],["burpee",10],
		["crunch",20],["pushup",20],["squat",20],["burpee",20],
		["crunch",30],["pushup",30],["squat",30],["burpee",30],
		["crunch",20],["pushup",20],["squat",20],["burpee",20],
		["crunch",10],["pushup",10],["squat",10],["burpee",10],
		],	
	"VRWorkout challenge": [
		["stand",30],["sprint",20],["crunch",20],["squat",20],
		["pushup",25],["jump",30],["squat",20],["burpee",25],
		["sprint",30],["pushup",30],["stand",30],["sprint",25],
		["crunch",30],["stand",15],["burpee",30],["crunch",25],
	],	
	"SideQuest Fitness": [
		["stand",20],["squat",15],["stand",20],["sprint",20],
		["jump",20],["squat",20],["crunch",20],["squat",20],
		["pushup",20],["stand",30],["sprint",20],["squat",30],
		["crunch",30],["sprint",25],["pushup",20]	
	],
	"VAL Winter Games": [
		["stand",10],["jump",20],["squat",30],["crunch",30],
		["sprint",30],["squat",40],["pushup",35],["stand",20],
		["pushup",30],["jump",30],["squat",20],["sprint",30],
		["crunch",40]
	]

}

var achievement_displays = {
	"VALWINTERGAMESRANKC": {
		"image_url": "res://assets/achievements/wintergames_rank_c.png",
		"name": "VAL Winter Games RANK C"
	},
	"VALWINTERGAMESRANKB": {
		"image_url": "res://assets/achievements/wintergames_rank_b.png",
		"name": "VAL Winter Games RANK B"
	},
	"VALWINTERGAMESRANKA": {
		"image_url": "res://assets/achievements/wintergames_rank_a.png",
		"name": "VAL Winter Games RANK A"
	}
}

var predefined_achievements = {
		"sidequest" : [
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.SCORE,
				 "limit": 60,
				 "achievement": "SIDEQUESTFITNESSWEEK21",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.DURATION,
				 "limit": 360,
				 "achievement": "SIDEQUESTFITNESSWEEK21",
				 "partial": true
				}
			],
		"valwintergames" : [
				#Rank C
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.SCORE,
				 "limit": 75,
				 "achievement": "VALWINTERGAMESRANKC",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.DURATION,
				 "limit": 600,
				 "achievement": "VALWINTERGAMESRANKC",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.START_TIME,
				 "limit": 1613689201,
				 "achievement": "VALWINTERGAMESRANKC",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.END_TIME,
				 "limit": 1616281199,
				 "achievement": "VALWINTERGAMESRANKC",
				 "partial": true
				},
				#Rank B
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.SCORE,
				 "limit": 85,
				 "achievement": "VALWINTERGAMESRANKB",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.DURATION,
				 "limit": 600,
				 "achievement": "VALWINTERGAMESRANKB",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.START_TIME,
				 "limit": 1613689201,
				 "achievement": "VALWINTERGAMESRANKB",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.END_TIME,
				 "limit": 1616281199,
				 "achievement": "VALWINTERGAMESRANKB",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.MIN_DIFFICULTY,
				 "limit": 0.5,
				 "achievement": "VALWINTERGAMESRANKB",
				 "partial": true
				},
				#RANK A
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.SCORE,
				 "limit": 95,
				 "achievement": "VALWINTERGAMESRANKA",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.DURATION,
				 "limit": 600,
				 "achievement": "VALWINTERGAMESRANKA",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.START_TIME,
				 "limit": 1613689201,
				 "achievement": "VALWINTERGAMESRANKA",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.END_TIME,
				 "limit": 1616281199,
				 "achievement": "VALWINTERGAMESRANKA",
				 "partial": true
				},
				{"type": AchievementEvaluator.ACHIEVEMENT_TYPES.MIN_DIFFICULTY,
				 "limit": 1.5,
				 "achievement": "VALWINTERGAMESRANKA",
				 "partial": true
				}


			]
	}
	
var exercise_collection_names = ["Leg work", "Developers choice","Ground work","Strength workout", "All but Burpees"]

var exercise_collections = [
	[
		{"setting":"game/exercise/jump",
		 "value": true,
		 "description": "Jumping"
		},
		{"setting":"game/exercise/squat",
		 "value": true,
		 "description": "Squats"
		},
		{"setting":"game/exercise/stand",
		 "value": true,
		 "description": "Standing"
		},
		{"setting":"game/exercise/strength_focus",
		 "value": false,
		 "description": "Strength	 Focus"
		},
	],
	[
		{"setting":"game/exercise/jump",
		 "value": true,
		 "description": "Jumping"
		},
		{"setting":"game/exercise/squat",
		 "value": true,
		 "description": "Squats"
		},
		{"setting":"game/exercise/stand",
		 "value": true,
		 "description": "Standing"
		},
		{"setting":"game/exercise/duck",
		 "value": true,
		 "description": "Ducking"
		},
		{"setting":"game/exercise/pushup",
		 "value": true,
		 "description": "Pushups"
		},
		{"setting":"game/exercise/crunch",
		 "value": true,
		 "description": "Crunches"
		},
		{"setting":"game/exercise/burpees",
		 "value": true,
		 "description": "Burpees"
		},
		{"setting":"game/exercise/sprint",
		 "value": true,
		 "description": "Sprinting"
		},
		{"setting":"game/exercise/strength_focus",
		 "value": false,
		 "description": "Strength Focus"
		},
	],
	[
		{"setting":"game/exercise/squat",
		 "value": true,
		 "description": "Squats"
		},
		{"setting":"game/exercise/pushup",
		 "value": true,
		 "description": "Pushups"
		},
		{"setting":"game/exercise/crunch",
		 "value": true,
		 "description": "Crunches"
		},
		{"setting":"game/exercise/burpees",
		 "value": true,
		 "description": "Standing"
		},
		{"setting":"game/exercise/strength_focus",
		 "value": false,
		 "description": "Strength Focus"
		},
	], [
		{"setting":"game/exercise/squat",
		 "value": true,
		 "description": "Squats"
		},
		{"setting":"game/exercise/stand",
		 "value": true,
		 "description": "Standing"
		},
		{"setting":"game/exercise/duck",
		 "value": true,
		 "description": "Ducking"
		},
		{"setting":"game/exercise/pushup",
		 "value": true,
		 "description": "Pushups"
		},
		{"setting":"game/exercise/crunch",
		 "value": true,
		 "description": "Crunches"
		},
		{"setting":"game/exercise/burpees",
		 "value": true,
		 "description": "Burpees"
		},
		{"setting":"game/exercise/sprint",
		 "value": true,
		 "description": "Sprinting"
		},
		{"setting":"game/exercise/strength_focus",
		 "value": true,
		 "description": "Strength Focus"
		},
	],		
		[
		{"setting":"game/exercise/squat",
		 "value": true,
		 "description": "Squats"
		},
		{"setting":"game/exercise/stand",
		 "value": true,
		 "description": "Standing"
		},
		{"setting":"game/exercise/stand/windmill",
		 "value": true,
		 "description": "Windmill"
		},
		{"setting":"game/exercise/duck",
		 "value": true,
		 "description": "Ducking"
		},
		{"setting":"game/exercise/jump",
		 "value": true,
		 "description": "Jumping"
		},
		{"setting":"game/exercise/pushup",
		 "value": true,
		 "description": "Pushups"
		},
		{"setting":"game/exercise/crunch",
		 "value": true,
		 "description": "Crunches"
		},
		{"setting":"game/exercise/parcour",
		 "value": true,
		 "description": "Parcour"
		},
		{"setting":"game/exercise/hold_cues",
		 "value": true,
		 "description": "Hold and follow"
		},
		{"setting":"game/exercise/sprint",
		 "value": true,
		 "description": "Sprinting"
		},
		{"setting":"game/exercise/strength_focus",
		 "value": false,
		 "description": "Strength Focus"
		},	
	],
]

var exercise_model = {
	"cardio": {
		"exercise_state_model": { CueState.STAND: { CueState.SQUAT: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10, CueState.JUMP: 10, CueState.BURPEE: 10, CueState.SPRINT: 10, CueState.WEIGHTS: 10},
						CueState.SQUAT: { CueState.STAND: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10, CueState.SPRINT: 10},
						CueState.PUSHUP: { CueState.STAND: 10, CueState.SQUAT: 10, CueState.BURPEE: 10, CueState.SPRINT: 10},
						CueState.CRUNCH: { CueState.STAND: 10, CueState.SQUAT: 10, CueState.SPRINT: 10, CueState.JUMP: 5},
						CueState.JUMP: {CueState.STAND: 50, CueState.BURPEE: 10, CueState.SQUAT: 10, CueState.CRUNCH: 10}, 
						CueState.BURPEE: {CueState.STAND: 50, CueState.CRUNCH: 10, CueState.SQUAT: 10, CueState.PUSHUP: 10}, 
						CueState.SPRINT: {CueState.STAND: 50, CueState.JUMP: 10, CueState.SQUAT: 10}, 
						CueState.YOGA: { CueState.STAND: 50 },
						CueState.PARCOUR: { CueState.STAND: 50 },
						CueState.WEIGHTS: { CueState.STAND: 50 },
						},
#		"pushup_state_model": { PushupState.REGULAR : { PushupState.LEFT_HAND : 15, PushupState.RIGHT_HAND: 15, PushupState.LEFT_SIDEPLANK: 10, PushupState.RIGHT_SIDEPLANK: 10},
#						PushupState.LEFT_HAND : { PushupState.REGULAR: 25, PushupState.RIGHT_HAND: 5, PushupState.RIGHT_SIDEPLANK: 10},
#						PushupState.RIGHT_HAND : { PushupState.REGULAR: 25, PushupState.LEFT_HAND: 5, PushupState.LEFT_SIDEPLANK: 10},
#						PushupState.LEFT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.RIGHT_HAND: 10},
#						PushupState.RIGHT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.LEFT_HAND: 10},
#						},
		"pushup_state_model": { PushupState.REGULAR : { PushupState.LEFT_HAND : 15, PushupState.RIGHT_HAND: 15, PushupState.LEFT_SIDEPLANK: 10, PushupState.RIGHT_SIDEPLANK: 10,PushupState.LEFT_HAND_HOLD: 15,PushupState.RIGHT_HAND_HOLD: 5},
						PushupState.LEFT_HAND : { PushupState.REGULAR: 25, PushupState.RIGHT_HAND: 5, PushupState.LEFT_HAND_HOLD: 5, PushupState.RIGHT_SIDEPLANK: 10},
						PushupState.RIGHT_HAND : { PushupState.REGULAR: 25, PushupState.LEFT_HAND: 5, PushupState.RIGHT_HAND_HOLD: 5, PushupState.LEFT_SIDEPLANK: 10},
						PushupState.LEFT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.RIGHT_HAND: 10,  PushupState.RIGHT_HAND_HOLD: 10},
						PushupState.RIGHT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.LEFT_HAND: 10, PushupState.LEFT_HAND_HOLD: 10},
						PushupState.LEFT_HAND_HOLD : { PushupState.REGULAR: 25, PushupState.RIGHT_HAND: 5, PushupState.RIGHT_HAND_HOLD: 5, PushupState.RIGHT_SIDEPLANK: 10},
						PushupState.RIGHT_HAND_HOLD : { PushupState.REGULAR: 25, PushupState.LEFT_HAND: 5, PushupState.LEFT_HAND_HOLD: 5,PushupState.LEFT_SIDEPLANK: 10},
						},
		"squat_state_model": { SquatState.HEAD : { SquatState.LEFT_HAND : 13, SquatState.RIGHT_HAND : 13, SquatState.DOUBLE_SWING : 25,  SquatState.CROSS_CUT : 25},
								SquatState.LEFT_HAND  : { SquatState.HEAD: 30,  SquatState.RIGHT_HAND: 30, SquatState.DOUBLE_SWING : 25},
								SquatState.RIGHT_HAND  : { SquatState.HEAD: 30,  SquatState.LEFT_HAND: 30, SquatState.DOUBLE_SWING : 25},
								SquatState.DOUBLE_SWING  : { SquatState.HEAD: 40},
								SquatState.CROSS_CUT  : { SquatState.HEAD: 30},
						},
		"stand_state_model" : { StandState.REGULAR : { StandState.DOUBLE_SWING: 5, StandState.WINDMILL_TOE: 15,  StandState.PARCOUR: 5, StandState.HOLD_CUE: 15},
						StandState.DOUBLE_SWING : { StandState.REGULAR: 30, StandState.WINDMILL_TOE: 15,  StandState.PARCOUR: 5, StandState.HOLD_CUE: 15},
						StandState.WINDMILL_TOE : { StandState.REGULAR: 27, StandState.DOUBLE_SWING: 5,  StandState.PARCOUR: 5},
						StandState.PARCOUR : { StandState.DOUBLE_SWING: 10, StandState.WINDMILL_TOE: 30, StandState.REGULAR: 40},
						StandState.HOLD_CUE : { StandState.DOUBLE_SWING: 5, StandState.REGULAR: 45},
		},
		"crunch_state_model" : { CrunchState.HEAD : { CrunchState.HAND: 70, CrunchState.MEDIUM_HOLD: 10},
						CrunchState.HAND : { CrunchState.HEAD: 70, CrunchState.MEDIUM_HOLD: 10},
						CrunchState.MEDIUM_HOLD : { CrunchState.HEAD: 20 },
		},
		"rebalance_exercises": true
		},
	"strength": {
		"exercise_state_model": { CueState.STAND: { CueState.SQUAT: 20, CueState.PUSHUP: 20, CueState.CRUNCH: 5, CueState.JUMP: 1, CueState.BURPEE: 20, CueState.SPRINT: 1, CueState.WEIGHTS: 1},
						CueState.SQUAT: { CueState.STAND: 10, CueState.PUSHUP: 50, CueState.CRUNCH: 5, CueState.BURPEE: 10},
						CueState.PUSHUP: { CueState.STAND: 10, CueState.SQUAT: 35, CueState.BURPEE: 10, CueState.CRUNCH: 10},
						CueState.CRUNCH: { CueState.PUSHUP: 25, CueState.SQUAT: 25, CueState.JUMP: 10},
						CueState.JUMP: {CueState.SQUAT: 50, CueState.PUSHUP: 25, CueState.BURPEE: 10, CueState.CRUNCH: 10}, 
						CueState.BURPEE: {CueState.SQUAT: 50, CueState.STAND: 45, CueState.PUSHUP: 5, CueState.CRUNCH: 1 }, 
						CueState.SPRINT: {CueState.SQUAT: 20, CueState.PUSHUP: 20, CueState.CRUNCH: 5, CueState.JUMP: 1, CueState.BURPEE: 20}, 
						CueState.YOGA: { CueState.STAND: 50 },
						CueState.PARCOUR: { CueState.STAND: 50 },
						CueState.WEIGHTS: { CueState.STAND: 50 },
						},
		"pushup_state_model": { PushupState.REGULAR : { PushupState.LEFT_HAND : 1, PushupState.RIGHT_HAND: 1, PushupState.LEFT_SIDEPLANK: 1, PushupState.RIGHT_SIDEPLANK: 1},
						PushupState.LEFT_HAND : { PushupState.REGULAR: 100},
						PushupState.RIGHT_HAND : { PushupState.REGULAR: 100},
						PushupState.LEFT_SIDEPLANK : { PushupState.REGULAR: 100},
						PushupState.RIGHT_SIDEPLANK : { PushupState.REGULAR: 100},
						},
		"squat_state_model": { SquatState.HEAD : { SquatState.LEFT_HAND : 5, SquatState.RIGHT_HAND : 5, SquatState.CROSS_CUT: 25},
								SquatState.LEFT_HAND  : { SquatState.HEAD: 90,  SquatState.RIGHT_HAND: 5},
								SquatState.RIGHT_HAND  : { SquatState.HEAD: 90,  SquatState.LEFT_HAND: 5},
								SquatState.CROSS_CUT  : { SquatState.HEAD: 30},
						},
		"stand_state_model" : { StandState.REGULAR : { },
					},
		"crunch_state_model" : { CrunchState.HEAD : { CrunchState.HAND: 70, CrunchState.MEDIUM_HOLD: 10},
						CrunchState.HAND : { CrunchState.HEAD: 70, CrunchState.MEDIUM_HOLD: 10},
						CrunchState.MEDIUM_HOLD : { CrunchState.HEAD: 20 },
		},

		"rebalance_exercises": false
		},
	}
	
var difficulty_weight_adjustments = {
	"easy" : {
		CueState.STAND: 1.2,
		CueState.SQUAT: 1.2,
		CueState.PUSHUP: 0.5,
		CueState.CRUNCH: 0.7,
		CueState.JUMP: 1.5,
		CueState.BURPEE: 0.0,
		CueState.SPRINT: 1.0,
		CueState.YOGA: 1.0,
		CueState.PARCOUR: 1.0,
		CueState.WEIGHTS: 1.0
		},
	"medium" : {
		CueState.STAND: 0.8,
		CueState.SQUAT: 0.8,
		CueState.PUSHUP: 1.0,
		CueState.CRUNCH: 1.0,
		CueState.JUMP: 0.7,
		CueState.BURPEE: 0.3,
		CueState.SPRINT: 1.0,
		CueState.YOGA: 1.0,
		CueState.PARCOUR: 1.0,
		CueState.WEIGHTS: 1.0
		},
	"hard" : {
		CueState.STAND: 0.1,
		CueState.SQUAT: 0.1,
		CueState.PUSHUP: 2.2,
		CueState.CRUNCH: 1.7,
		CueState.JUMP: 0.5,
		CueState.BURPEE: 1.3,
		CueState.SPRINT: 1.0,
		CueState.YOGA: 1.0,
		CueState.PARCOUR: 1.0,
		CueState.WEIGHTS: 1.0
	},
}	
	
var default_state_transition_pause = 1.5

var state_transition_time = {
	"%d-%d"%[CueState.PUSHUP, CueState.CRUNCH]: 3.0,
	"%d-%d"%[CueState.CRUNCH, CueState.PUSHUP]: 3.0,
	"%d-%d"%[CueState.PUSHUP, CueState.STAND]: 3.0,
	"%d-%d"%[CueState.PUSHUP, CueState.SPRINT]: 3.0,
	"%d-%d"%[CueState.PUSHUP, CueState.JUMP]: 3.0,
	"%d-%d"%[CueState.PUSHUP, CueState.SQUAT]: 3.0,
	"%d-%d"%[CueState.CRUNCH, CueState.STAND]: 3.0,
	"%d-%d"%[CueState.CRUNCH, CueState.SPRINT]: 3.0,
	"%d-%d"%[CueState.CRUNCH, CueState.JUMP]: 3.0,
	"%d-%d"%[CueState.CRUNCH, CueState.SQUAT]: 3.0,
	"%d-%d"%[CueState.STAND, CueState.CRUNCH]: 3.0,
	"%d-%d"%[CueState.SPRINT, CueState.CRUNCH]: 3.0,
	"%d-%d"%[CueState.JUMP, CueState.CRUNCH]: 3.0,
	"%d-%d"%[CueState.SQUAT, CueState.CRUNCH]: 3.0,
}

	
	
var level_statistics_data = {}
	
func setup_globals():
	if demo_mode:
		setup_globals_demo()
	else:
		setup_globals_regular()
	

func setup_globals_demo():
	ProjectSettings.set("game/beast_mode", false)
	ProjectSettings.set("game/bpm", 120)
	ProjectSettings.set("game/exercise/jump", true)
	ProjectSettings.set("game/exercise/stand", true)
	ProjectSettings.set("game/exercise/squat", true)
	ProjectSettings.set("game/exercise/pushup", true)
	ProjectSettings.set("game/exercise/crunch", true)
	ProjectSettings.set("game/exercise/burpees", true)
	ProjectSettings.set("game/exercise/parcour", false)
	ProjectSettings.set("game/exercise/duck", true)
	ProjectSettings.set("game/exercise/weights", false)
	ProjectSettings.set("game/exercise/sprint", true)
	ProjectSettings.set("game/exercise/kneesaver", false)
	ProjectSettings.set("game/exercise/stand/windmill", true)
	ProjectSettings.set("game/exercise/stand/curved", false)
	ProjectSettings.set("game/exercise/yoga", false)
	ProjectSettings.set("game/exercise/hold_cues", false)
	ProjectSettings.set("game/exercise/strength_focus", false)
	ProjectSettings.set("game/is_oculusquest", false)
	ProjectSettings.set("game/hud_enabled", true)

	ProjectSettings.set("game/target_hr", 140)
	ProjectSettings.set("game/player_height", 1.8)
	ProjectSettings.set("game/exercise_duration_avg", 25.0)
	ProjectSettings.set("game/external_songs", null)
	ProjectSettings.set("game/equalizerr", true)
	ProjectSettings.set("game/portal_connection", true)
	
	ProjectSettings.set("game/instructor", true)
	ProjectSettings.set("game/easy_transition", true)
	
	ProjectSettings.set("game/override_beats", false)
	ProjectSettings.set("game/record_tracker", true)
	ProjectSettings.set("game/environment", "calm")


	

func setup_globals_regular():
	ProjectSettings.set("game/beast_mode", false)
	ProjectSettings.set("game/bpm", 140)
	ProjectSettings.set("game/exercise/jump", true)
	ProjectSettings.set("game/exercise/stand", true)
	ProjectSettings.set("game/exercise/squat", true)
	ProjectSettings.set("game/exercise/pushup", true)
	ProjectSettings.set("game/exercise/crunch", true)
	ProjectSettings.set("game/exercise/burpees", false)
	ProjectSettings.set("game/exercise/parcour", false)
	ProjectSettings.set("game/exercise/weights", false)
	ProjectSettings.set("game/exercise/duck", true)
	ProjectSettings.set("game/exercise/sprint", true)
	ProjectSettings.set("game/exercise/stand/windmill", true)
	ProjectSettings.set("game/exercise/stand/curved", false)
	ProjectSettings.set("game/exercise/kneesaver", false)
	ProjectSettings.set("game/exercise/strength_focus", false)
	ProjectSettings.set("game/exercise/yoga", false)
	ProjectSettings.set("game/exercise/hold_cues", false)


	ProjectSettings.set("game/is_oculusquest", false)
	ProjectSettings.set("game/hud_enabled", false)
	ProjectSettings.set("game/equalizer", true)

	ProjectSettings.set("game/target_hr", 140)
	ProjectSettings.set("game/player_height", 1.8)
	ProjectSettings.set("game/exercise_duration_avg", 25.0)
	ProjectSettings.set("game/external_songs", null)
	ProjectSettings.set("game/portal_connection", false)
	ProjectSettings.set("game/instructor", true)
	ProjectSettings.set("game/easy_transition", true)
	ProjectSettings.set("game/override_beats", false)
	ProjectSettings.set("game/record_tracker", false)
	ProjectSettings.set("game/environment", "calm")





var exercise_state_list

func _ready():
	trackers = []
	exercise_state_list = []
	pass


func click_audio():
	$Click.play()	
