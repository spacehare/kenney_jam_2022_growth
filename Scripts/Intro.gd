extends Control

func _ready():
	$Radial.max_value = $Timer.wait_time
#	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func _process(_delta):
	$Radial.value = $Timer.wait_time - $Timer.time_left


func _input(event):
	if event.is_action_pressed("ui_accept"):
		change()


func _on_Timer_timeout():	change()
func _on_Button_pressed():	change()


func _on_LinkJam_pressed():		OS.shell_open("https://itch.io/jam/kenney-jam-2022")
func _on_LinkHare_pressed():	OS.shell_open("https://hare.itch.io")
func _on_LinkAlex_pressed():	OS.shell_open("https://jelloboy.itch.io/")


func change():
	get_tree().change_scene("res://Scenes/Main.tscn")



