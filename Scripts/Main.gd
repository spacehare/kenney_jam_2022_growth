extends Node2D

export(PackedScene) var sprout_scene

#var debug_missions_text := ["ERROR!"]
var cursor_position := Vector2.ZERO

func _ready():
	Auto.debug_view = false
	Auto.set_debug_visible()
#	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	pass

#func _process(_delta):
#	$Hints/HintLMB.set_modulate = Color.white if Auto.lmb_highlight else Color(0.227451, 0.227451, 0.227451)
	
func _physics_process(_delta):
#	cursor_position = get_viewport().get_mouse_position()
#	cursor_position = get_global_mouse_position()
	cursor_position = get_local_mouse_position()
#	get_global_mouse_position()
#	debug_missions_text_update()

	$HUD/LabelMissions.text = debug_missions_text_update()

func _mook_death():
	$sfxMookDeath.play()

func debug_missions_text_update() -> String:
	var debug_mission_text : String
	for m in self.get_children():
		var i = 0
		if m.is_in_group("mook"): # and m.mission != m.Mission.DEAD
#			debug_mission_text += m.name + "....." + str(m.get_instance_id()) + "....." + str(m.Mission.keys()[m.mission]) + "\n"
			debug_mission_text += pad(m.name, 24)\
			+ pad(str(m.get_instance_id()), 8)\
			+ str(m.Mission.keys()[m.mission]) + "\n"
			i += 1
#		if i == debug_missions_text.size() - 1:
#			i = 0
	return debug_mission_text

func pad(input, howmany, symbol = ".") -> String:
	var output = input
	var how_much_padding
	how_much_padding = howmany - input.length()
	for i in how_much_padding:
		output += symbol
	return output
	
func _input(event): 
	if event.is_action_pressed("debug_info"):
		Auto.debug_view = !Auto.debug_view # this goes before so i don't have to double input ctrl+h
#		get_tree().debug_collisions_hint = debug_view
		Auto.set_debug_visible()
			
	if event.is_action_pressed("middle_click"):
		var new_sprout = sprout_scene.instance()
		add_child(new_sprout)
		new_sprout.position = get_global_mouse_position()
		
	

		
#	$Food.satiation
	
#	$debugvector.position = cursor_position
#	if event is InputEventMouseButton:
#		$debugvector.position = event.position
#		print(event.position)
#	if event.is_action("click"):
#		print(event.position)
