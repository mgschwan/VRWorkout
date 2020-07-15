extends Node

var detail_selection_mode = true
var trackers = null
var difficulty = 0
var override_beatmap = false

enum CueState {
	STAND = 0,
	SQUAT = 1,
	PUSHUP = 2,
	CRUNCH = 3,
	JUMP = 4,
	BURPEE = 5,
	SPRINT = 6,
	YOGA = 7,
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
};	
	
enum SquatState {
	HEAD = 0,
	LEFT_HAND = 1,
	RIGHT_HAND = 2
};	



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
]
	
	

var exercise_model = {
	"cardio": {
		"exercise_state_model": { CueState.STAND: { CueState.SQUAT: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10, CueState.JUMP: 10, CueState.BURPEE: 10, CueState.SPRINT: 10},
						CueState.SQUAT: { CueState.STAND: 10, CueState.PUSHUP: 10, CueState.CRUNCH: 10, CueState.SPRINT: 10},
						CueState.PUSHUP: { CueState.STAND: 10, CueState.SQUAT: 10, CueState.BURPEE: 10},
						CueState.CRUNCH: { CueState.STAND: 10, CueState.SQUAT: 10},
						CueState.JUMP: {CueState.STAND: 50, CueState.BURPEE: 10}, 
						CueState.BURPEE: {CueState.STAND: 50}, 
						CueState.SPRINT: {CueState.STAND: 50, CueState.JUMP: 10, CueState.SQUAT: 10}, 
						CueState.YOGA: { CueState.STAND: 50 },
						},
		"pushup_state_model": { PushupState.REGULAR : { PushupState.LEFT_HAND : 15, PushupState.RIGHT_HAND: 15, PushupState.LEFT_SIDEPLANK: 10, PushupState.RIGHT_SIDEPLANK: 10},
						PushupState.LEFT_HAND : { PushupState.REGULAR: 25, PushupState.RIGHT_HAND: 5, PushupState.RIGHT_SIDEPLANK: 10},
						PushupState.RIGHT_HAND : { PushupState.REGULAR: 25, PushupState.LEFT_HAND: 5, PushupState.LEFT_SIDEPLANK: 10},
						PushupState.LEFT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.RIGHT_HAND: 10},
						PushupState.RIGHT_SIDEPLANK : { PushupState.REGULAR: 20, PushupState.LEFT_HAND: 10},
						},
		"squat_state_model": { SquatState.HEAD : { SquatState.LEFT_HAND : 13, SquatState.RIGHT_HAND : 13},
								SquatState.LEFT_HAND  : { SquatState.HEAD: 30,  SquatState.RIGHT_HAND: 40},
								SquatState.RIGHT_HAND  : { SquatState.HEAD: 30,  SquatState.LEFT_HAND: 40},
						},
		"rebalance_exercises": true
		},
	"strength": {
		"exercise_state_model": { CueState.STAND: { CueState.SQUAT: 20, CueState.PUSHUP: 20, CueState.CRUNCH: 5, CueState.JUMP: 1, CueState.BURPEE: 20, CueState.SPRINT: 1},
						CueState.SQUAT: { CueState.STAND: 10, CueState.PUSHUP: 50, CueState.CRUNCH: 5, CueState.BURPEE: 10},
						CueState.PUSHUP: { CueState.STAND: 10, CueState.SQUAT: 35, CueState.BURPEE: 10, CueState.CRUNCH: 10},
						CueState.CRUNCH: { CueState.PUSHUP: 25, CueState.SQUAT: 25},
						CueState.JUMP: {CueState.SQUAT: 50, CueState.PUSHUP: 25, CueState.BURPEE: 10}, 
						CueState.BURPEE: {CueState.SQUAT: 50, CueState.STAND: 45, CueState.PUSHUP: 5 }, 
						CueState.SPRINT: {CueState.SQUAT: 20, CueState.PUSHUP: 20, CueState.CRUNCH: 5, CueState.JUMP: 1, CueState.BURPEE: 20}, 
						CueState.YOGA: { CueState.STAND: 50 },
						},
		"pushup_state_model": { PushupState.REGULAR : { PushupState.LEFT_HAND : 1, PushupState.RIGHT_HAND: 1, PushupState.LEFT_SIDEPLANK: 1, PushupState.RIGHT_SIDEPLANK: 1},
						PushupState.LEFT_HAND : { PushupState.REGULAR: 100},
						PushupState.RIGHT_HAND : { PushupState.REGULAR: 100},
						PushupState.LEFT_SIDEPLANK : { PushupState.REGULAR: 100},
						PushupState.RIGHT_SIDEPLANK : { PushupState.REGULAR: 100},
						},
		"squat_state_model": { SquatState.HEAD : { SquatState.LEFT_HAND : 5, SquatState.RIGHT_HAND : 5},
								SquatState.LEFT_HAND  : { SquatState.HEAD: 90,  SquatState.RIGHT_HAND: 5},
								SquatState.RIGHT_HAND  : { SquatState.HEAD: 90,  SquatState.LEFT_HAND: 5},
						},
		"rebalance_exercises": false
		},
	}
	
	
	

func setup_globals():
	ProjectSettings.set("game/beast_mode", false)
	ProjectSettings.set("game/bpm", 120)
	ProjectSettings.set("game/exercise/jump", false)
	ProjectSettings.set("game/exercise/stand", false)
	ProjectSettings.set("game/exercise/squat", false)
	ProjectSettings.set("game/exercise/pushup", true)
	ProjectSettings.set("game/exercise/crunch", false)
	ProjectSettings.set("game/exercise/burpees", false)
	ProjectSettings.set("game/exercise/duck", false)
	ProjectSettings.set("game/exercise/sprint", false)
	ProjectSettings.set("game/exercise/kneesaver", false)
	ProjectSettings.set("game/exercise/yoga", false)
	ProjectSettings.set("game/exercise/strength_focus", false)
	ProjectSettings.set("game/is_oculusquest", false)
	ProjectSettings.set("game/hud_enabled", true)

	ProjectSettings.set("game/target_hr", 140)
	ProjectSettings.set("game/player_height", 1.8)
	ProjectSettings.set("game/external_songs", null)
	ProjectSettings.set("game/equalizerr", true)

var level_statistics_data = {}

#func setup_globals():
#	ProjectSettings.set("game/beast_mode", false)
#	ProjectSettings.set("game/bpm", 140)
#	ProjectSettings.set("game/exercise/jump", true)
#	ProjectSettings.set("game/exercise/stand", true)
#	ProjectSettings.set("game/exercise/squat", true)
#	ProjectSettings.set("game/exercise/pushup", true)
#	ProjectSettings.set("game/exercise/crunch", true)
#	ProjectSettings.set("game/exercise/burpees", false)
#	ProjectSettings.set("game/exercise/duck", true)
#	ProjectSettings.set("game/exercise/sprint", true)
#	ProjectSettings.set("game/exercise/kneesaver", false)
#	ProjectSettings.set("game/exercise/strength_focus", false)
#	ProjectSettings.set("game/exercise/yoga", false)
#
#	ProjectSettings.set("game/is_oculusquest", false)
#	ProjectSettings.set("game/hud_enabled", false)
#	ProjectSettings.set("game/equalizer", true)
#
#	ProjectSettings.set("game/target_hr", 140)
#	ProjectSettings.set("game/player_height", 1.8)
#	ProjectSettings.set("game/external_songs", null)


func _ready():
	trackers = []
	pass
	
