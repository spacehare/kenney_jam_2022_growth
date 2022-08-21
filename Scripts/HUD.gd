extends Control



func _input(event):
	if event is InputEventMouseMotion:
		var cursor = get_local_mouse_position()
		$Area2D.position = cursor
		$MouseRelease.position = cursor
		$Rain.position = cursor  + Vector2(0,-16)
		$AboveCursor.position = cursor + Vector2(0,-48)
		$Magic.position = $AboveCursor.position
		
	if event.is_action_pressed("click"):
		$Rain.emitting = true
	elif event.is_action_released("click"):
		$Rain.emitting = false
	if event.is_action_pressed("right_click"):
		$Magic.emitting = true
	elif event.is_action_released("right_click"):
		$Magic.emitting = false




func _process(delta):
	$StatMana.text = str(Auto.mana) #round(Auto.mana) as String
	$ProgressBar.value = Auto.mana


func _on_Area2D_area_entered(area):
	pass


func _on_Area2D_area_exited(area):
	pass
