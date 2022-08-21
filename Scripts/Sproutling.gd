extends KinematicBody2D

# https://godotengine.org/qa/47374/random-colour-in-godot



enum Mission {IDLE, JUST_SPAWNED, WANDER, GOTO, HUNT, EAT, DEAD, BORED}
export(Mission) var mission

var max_satiety : int = 60
var hunt_satiety : int = 20
var age : int = 0
var happiness := 100.0
var satiety : int = max_satiety / 2
export var grow : int = Auto.STAGE_2

const max_speed := 20.0
var achievable_speed := 0.0

var speed := 22.0
var velocity := Vector2.ZERO
var close_enough_distance := 6.0

signal death

export(PackedScene) var goblin_scene
#const GROW_INTO = preload("res://Scenes/entities/Goblin.tscn")



func _ready():
	$Target.position = position
	Auto.set_debug_visible()
	mission = Mission.JUST_SPAWNED
	randomize()

	self.add_to_group("mook")
	self.add_to_group("ling")


func _draw():
	if Auto.debug_view == true:
		draw_line(to_local(position), to_local($Target.position), Color.red, 1)
		draw_circle(to_local($Target.position), 4, Color.blue)


func _physics_process(delta):
	update()
	$StatSatiety.text = satiety as String
	$StatAge.text = age as String
	$StatHappiness.text = ("%.1f" % happiness) as String

	if not mission == Mission.BORED:
		happiness -= 1 * delta
	
	if satiety < hunt_satiety:
		mission = Mission.HUNT
	elif happiness < 20:
		mission = Mission.BORED
	
	match mission:
		Mission.JUST_SPAWNED: 
			$Target.position = position
			achievable_speed = max_speed / 2
		
		Mission.IDLE: {}
		Mission.WANDER: {}
		Mission.GOTO: {}
		Mission.HUNT: 
			var group
			var food_available : bool = true
			if not get_tree().get_nodes_in_group("food").empty():
				group = "food"
			else:
				food_available = false
			if food_available:
				var meal_node = find_closest_node(group)
				if can_hunt():
					move_to(meal_node.position)
					if position.distance_to(meal_node.position) < close_enough_distance:
						eat(meal_node)
						mission = Mission.IDLE
		Mission.BORED: 
			move_to(get_parent().cursor_position)
			if position.distance_to(get_parent().cursor_position) <= close_enough_distance:
				happiness += 10 * delta
			if happiness > 99:
				mission = Mission.IDLE


func _on_SatietyTimer_timeout():
	satiety -= 1
	if satiety == 0:
		die()


func _on_AgeTimer_timeout():
	age += 1
	if age >= grow:
		grow()


func grow():
	var gobbo = goblin_scene.instance()
	get_parent().add_child(gobbo)
	gobbo.position = position
	gobbo.age = age
	gobbo.satiety = satiety
	gobbo.mission = Mission.JUST_SPAWNED
	self.queue_free()


func die():
	mission = Mission.DEAD
	$Sprite.play("dead")
	for t in get_children():
		if t is Timer:
			t.stop()
	emit_signal("death")
	$sfxDeath.play()
	
	
func move():
	# https://kidscancode.org/godot_recipes/ai/chase/
	if position.distance_to($Target.position) > close_enough_distance:
		velocity = move_and_slide(position.direction_to($Target.position) * speed)

func move_to(target):
	$Target.position = target
	move()
	
func find_closest_node(group) -> Node2D:
	# this function does not work, just gets first in array
	var options := get_tree().get_nodes_in_group(group)
	var targets = []
	var distances = []
	var index : int
	for option in options:
		var distance = position.distance_to(option.position)
		
#		var target_position = option.position
		targets.append(option.position)
		distances.append(distances)
		var prevdis = distances[index - 1] if not distances.empty() else 999
#		print (prevdis as String)
		index += 1
		
	return options.front()

func can_hunt() -> bool:
	if mission != Mission.DEAD:
		return satiety <= hunt_satiety
	else: return false

func eat(meal : Node2D):
	self.satiety += clamp(meal.satiation, 0, 100)
#	self.satiety += meal.satiation
	meal.queue_free()


func _on_AreaClickable_area_entered(area):
	pass # Replace with function body.
func _on_AreaClickable_area_exited(area):
	pass # Replace with function body.
