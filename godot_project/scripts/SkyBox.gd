extends Spatial

var blue_environment = null 
var red_environment = null 
var bright_environment = null 


var gu = GameUtilities.new()
var current_skybox = ""


func switch(value):
	if GameVariables.ar_mode:
		gu.activate_node(get_node("box3"))
		gu.deactivate_node(get_node("box1"))
	else:
		var blank_out = false
		if current_skybox != value:
			blank_out = true
			
		if blank_out and GameVariables.vr_camera:
			GameVariables.vr_camera.blackout_screen(true)

		gu.deactivate_node(get_node("box3"))
		if value == "angry":
			load_skybox("res://assets/skybox2", value)
		elif value == "bright":
			load_skybox("res://assets/skybox3", value)	
		else:
			load_skybox("res://assets/skybox", value)
		gu.activate_node(get_node("box1"))
		
		if blank_out and GameVariables.vr_camera:
			GameVariables.vr_camera.blackout_screen(false)
	
func switch_environment(value):
	ProjectSettings.set("game/stage", value)
	if value == "angry":
		get_viewport().get_camera().environment = red_environment
	elif value == "bright":
		get_viewport().get_camera().environment = bright_environment
	else:
		get_viewport().get_camera().environment = blue_environment

		
func load_skybox(dir, env):
	var config = gu.load_persistent_config("%s/config.json"%dir)
	skybox_rotation(config.get("rotate",false))
	switch_environment(config.get("environment",env))
	var it = load("%s/front.jpg"%dir)
	
	$box1/front.get_surface_material(0).albedo_texture = it

	it = load("%s/left.jpg"%dir)
	$box1/left.get_surface_material(0).albedo_texture = it

	it = load("%s/right.jpg"%dir)
	$box1/right.get_surface_material(0).albedo_texture = it

	it = load("%s/back.jpg"%dir)
	$box1/back.get_surface_material(0).albedo_texture = it

	it = load("%s/top.jpg"%dir)
	$box1/top.get_surface_material(0).albedo_texture = it

	it = load("%s/bottom.jpg"%dir)
	$box1/bottom.get_surface_material(0).albedo_texture = it

func skybox_rotation(value):
	if value:
		$AnimationPlayer.play("skybox_rotation",-1,0.05)
	else:
		$AnimationPlayer.stop()
		$AnimationPlayer.seek(0)

func _ready():
	red_environment = load("res://default_env_red.tres")
	blue_environment = load("res://default_env.tres")
	bright_environment = load("res://default_env_bright.tres")

	switch("calm")
