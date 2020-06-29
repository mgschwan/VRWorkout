extends Node

var detail_selection_mode = true
var trackers = null
var difficulty = 0



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
	ProjectSettings.set("game/bpm", 120)
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
	
