extends Control

var gu = GameUtilities.new()

func get_percent(good,total):
	var perc = 0
	if total > 0:
		perc = 100.0*float(good)/float(total)
	else:
		perc = 0
	return perc

func update_statistics():
	var result = gu.build_workout_statistic(GameVariables.level_statistics_data)
	print("Result: %s"%str(result))
	
	var good
	var total
	var perc = 0

	good = result["statistic"].get("stand",{}).get("good",0)
	total = result["statistic"].get("stand",{}).get("total",0)
	perc = get_percent(good,total)	
	$StandValue.value = perc
	$StandValue/Percent.text = "%.1f"%perc
	
	good = result["statistic"].get("squat",{}).get("good",0)
	total = result["statistic"].get("squat",{}).get("total",0)
	perc = get_percent(good,total)	
	$SquatValue.value = perc
	$SquatValue/Percent.text = "%.1f"%perc
	
	good = result["statistic"].get("pushup",{}).get("good",0)
	total = result["statistic"].get("pushup",{}).get("total",0)
	perc = get_percent(good,total)	
	$PushupValue.value = perc
	$PushupValue/Percent.text = "%.1f"%perc

	good = result["statistic"].get("jump",{}).get("good",0)
	total = result["statistic"].get("jump",{}).get("total",0)
	perc = get_percent(good,total)	
	$JumpValue.value = perc
	$JumpValue/Percent.text = "%.1f"%perc

	good = result["statistic"].get("sprint",{}).get("good",0)
	total = result["statistic"].get("sprint",{}).get("total",0)
	perc = get_percent(good,total)	
	$SprintValue.value = perc
	$SprintValue/Percent.text = "%.1f"%perc

	good = result["statistic"].get("crunch",{}).get("good",0)
	total = result["statistic"].get("crunch",{}).get("total",0)
	perc = get_percent(good,total)	
	$CrunchValue.value = perc
	$CrunchValue/Percent.text = "%.1f"%perc

	good = result["statistic"].get("burpee",{}).get("good",0)
	total = result["statistic"].get("burpee",{}).get("total",0)
	perc = get_percent(good,total)	
	$BurpeeValue.value = perc
	$BurpeeValue/Percent.text = "%.1f"%perc

	var val = result.get("difficulty_avg",0)
	total = 2.0
	perc = get_percent(val,total)	
	$DifficultyValue.value = perc
	$DifficultyValue/Percent.text = "%.1f"%perc

func _ready():
	update_statistics()

