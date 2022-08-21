extends Node2D

var age := 0.0
export var grow := Auto.STAGE_1
onready var seedling : int = round(grow * .333)
onready var adult : int = round(grow * .666)
var interactable : bool = false
var is_carrot = false

export(PackedScene) var sproutling_scene
export(PackedScene) var food_scene

#const stage := {
#	first = preload("res://resources/atlas_1bit/Sprout_1.atlastex"),
#	second = preload("res://resources/atlas_1bit/Sprout_1.atlastex"),
#	third = preload("res://resources/atlas_1bit/Sprout_1.atlastex"),
#	}
	
var microstage := [
preload("res://resources/atlas_1bit/Sprout_1.atlastex"),
preload("res://resources/atlas_1bit/Sprout_2.atlastex"),
]

func _ready():
	print(position)
	Auto.set_debug_visible()
#	add_to_group("sprout")
	
func _process(delta):
	$StatAge.text = str(age)
	
func _physics_process(delta):
	if interactable:
		if Input.is_action_pressed("click"):
			$AnimationPlayer.playback_speed = 4
			is_carrot = false
			age += 4.5 * delta
			Auto.mana -= 50 * delta
		elif Input.is_action_just_released("click"):
			$AnimationPlayer.playback_speed = 1
		
		if Input.is_action_pressed("right_click"):
			$AnimationPlayer.playback_speed = 4
			is_carrot = true
			age += 4.5 * delta
			Auto.mana -= 50 * delta
		elif Input.is_action_just_released("right_click"):
			$AnimationPlayer.playback_speed = 1
			

		


func _on_AgeTimer_timeout():
	age += 1
	if age >= seedling:
		$Sprite.texture = microstage[0]
	if age >= adult:
		$Sprite.texture = microstage[1]
	if age >= grow:
		grow()


func grow():
	if not is_carrot:
		var gobbo = sproutling_scene.instance()
		get_parent().add_child(gobbo)
		gobbo.position = position
		gobbo.age = age
		Auto.sproutling_hint = true
		self.queue_free()
	else:
		var carrot = food_scene.instance()
		get_parent().add_child(carrot)
		carrot.position = position
		Auto.carrot_hint = true
		self.queue_free()


func _on_Area2D_area_entered(area):
	$"../Hints/HintLMB".modulate = Auto.color_highlight
	get_parent().get_node("Hints/HintRMB").modulate = Auto.color_highlight
	$"../hintor".visible = true
	if Auto.sproutling_hint:
		$"../hintgoblin".visible = true
	if Auto.carrot_hint:
		$"../hintcarrot".visible = true
#	print ("sprout: cursor enter")
	$AnimationPlayer.play("wiggle")
	interactable = true


func _on_Area2D_area_exited(area):
	$"../Hints/HintLMB".modulate = Auto.color_dim
	get_parent().get_node("Hints/HintRMB").modulate = Auto.color_dim
	$"../hintor".visible = false
	$"../hintgoblin".visible = false
	$"../hintcarrot".visible = false
	$AnimationPlayer.play("RESET")
#	print ("sprout: cursor exit")
	interactable = false


func _on_Area2D_mouse_entered():
	print ("xxxxxxxxxx")
func _on_Area2D_mouse_exited():
	print ("yyyyyyyyyy")
