extends Node

var detail_selection_mode = true
var trackers = null
var difficulty = 0
var override_beatmap = false


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
		 "description": "Standing"
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
	],
]
	

#func setup_globals():
#	ProjectSettings.set("game/beast_mode", false)
#	ProjectSettings.set("game/bpm", 120)
#	ProjectSettings.set("game/exercise/jump", false)
#	ProjectSettings.set("game/exercise/stand", false)
#	ProjectSettings.set("game/exercise/squat", false)
#	ProjectSettings.set("game/exercise/pushup", false)
#	ProjectSettings.set("game/exercise/crunch", true)
#	ProjectSettings.set("game/exercise/burpees", false)
#	ProjectSettings.set("game/exercise/duck", false)
#	ProjectSettings.set("game/exercise/sprint", false)
#	ProjectSettings.set("game/exercise/kneesaver", false)
#	ProjectSettings.set("game/exercise/yoga", false)
#
#	ProjectSettings.set("game/is_oculusquest", false)
#	ProjectSettings.set("game/hud_enabled", false)
#
#	ProjectSettings.set("game/target_hr", 140)
#	ProjectSettings.set("game/external_songs", null)


func setup_globals():
	ProjectSettings.set("game/beast_mode", false)
	ProjectSettings.set("game/bpm", 140)
	ProjectSettings.set("game/exercise/jump", true)
	ProjectSettings.set("game/exercise/stand", true)
	ProjectSettings.set("game/exercise/squat", true)
	ProjectSettings.set("game/exercise/pushup", true)
	ProjectSettings.set("game/exercise/crunch", true)
	ProjectSettings.set("game/exercise/burpees", false)
	ProjectSettings.set("game/exercise/duck", true)
	ProjectSettings.set("game/exercise/sprint", true)
	ProjectSettings.set("game/exercise/kneesaver", false)
	ProjectSettings.set("game/exercise/yoga", false)

	ProjectSettings.set("game/is_oculusquest", false)
	ProjectSettings.set("game/hud_enabled", false)

	ProjectSettings.set("game/target_hr", 140)
	ProjectSettings.set("game/external_songs", null)




func _ready():
	trackers = []
	pass
	
