extends Node

var character = "easy"

var success_rates = {
	"easy" : {
		GameVariables.CueState.STAND: 0.7,
		GameVariables.CueState.SQUAT: 0.7,
		GameVariables.CueState.PUSHUP: 0.5,
		GameVariables.CueState.CRUNCH: 0.5,
		GameVariables.CueState.JUMP: 0.7,
		GameVariables.CueState.BURPEE: 0.5,
		GameVariables.CueState.SPRINT: 0.7,
		GameVariables.CueState.YOGA: 0.7
		},
	"medium" : {
		GameVariables.CueState.STAND: 0.8,
		GameVariables.CueState.SQUAT: 0.8,
		GameVariables.CueState.PUSHUP: 0.7,
		GameVariables.CueState.CRUNCH: 0.8,
		GameVariables.CueState.JUMP: 0.8,
		GameVariables.CueState.BURPEE: 0.7,
		GameVariables.CueState.SPRINT: 0.8,
		GameVariables.CueState.YOGA: 0.8
		},
	"hard" : {
		GameVariables.CueState.STAND: 0.9,
		GameVariables.CueState.SQUAT: 0.9,
		GameVariables.CueState.PUSHUP: 0.9,
		GameVariables.CueState.CRUNCH: 0.9,
		GameVariables.CueState.JUMP: 0.9,
		GameVariables.CueState.BURPEE: 0.9,
		GameVariables.CueState.SPRINT: 0.9,
		GameVariables.CueState.YOGA: 0.9
	},
}	


func cpu_hit(exercise):
	print ("Character: %s"%character)
	var cpu_strength = success_rates[character].get(exercise,0.5)
	
	var retVal = false
	if randf() < cpu_strength:
		#CPU scored a hit
		retVal = true
	return retVal







