extends Node2D

func update_data():
	var data = GameVariables.plugin_data.get("nightscout",{})
	var sgv = data.get("sgv",0)
	$SGV.bbcode_text="[center]%d[/center]"%int(sgv)
	
	var bgdelta = data.get("bgdelta",0)
	if bgdelta > 0:
		$BGDELTA.text = "+%d"%int(bgdelta)
	else:
		$BGDELTA.text = "%d"%int(bgdelta)
	
	
func _ready():
	update_data()	
	
