extends Object

class_name AchievementEvaluator

enum ACHIEVEMENT_TYPES {
	SCORE,
	DURATION
	}

var available_achievements = Array()


func _init(achievement_list):
	available_achievements = achievement_list


func evaluate_achievements(game_state):
	var retVal = []
	
	var achieved = {}
	
	var finished = game_state.get("level_finished", false)
	var points = game_state.get("points",0)
	var time = game_state.get("time",0)
	var score = game_state.get("vrw_score",0)
	
	for a in available_achievements:
		var name = a.get("achievement","UNKNOWN")
		var result = false
		if a.get("type",-1) == ACHIEVEMENT_TYPES.SCORE:
			#deactivated for now until the end of the fitness week# result = finished and score > a.get("limit",0)
			result = score > a.get("limit",0)
		elif a.get("type",-1) == ACHIEVEMENT_TYPES.DURATION:
			result = time > a.get("limit",0)

		if a.get("partial",false):
			achieved[name] = achieved.get(name,true) and result
		else:
			achieved[name] = result

	for identifier in achieved.keys():
		if achieved[identifier]:
			retVal.append({"achievement_identifier":identifier,"achieved":true})

	return retVal
