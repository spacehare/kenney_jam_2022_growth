extends KinematicBody2D

# https://godotengine.org/qa/47374/random-colour-in-godot
var colors := [
Color.aliceblue,Color.chartreuse,Color.darkcyan,
Color.darkgreen, Color.lightseagreen,Color.slateblue,
Color.lightgreen,Color.brown,Color.crimson,Color.magenta,
Color.maroon,Color.olive,Color.olivedrab,Color.seagreen,
Color.slateblue,Color.teal,Color.forestgreen,
Color.yellowgreen,Color.darkred,Color.darkolivegreen,
]


enum Mission {IDLE, JUST_SPAWNED, WANDER, BORED, GOTO, EAT, HUNT, DEAD, SLEEP, PLUCK, FARM, DEBUG}

export(Mission) var mission = Mission.IDLE
export var grow : int = Auto.STAGE_3

const max_satiety : int = 100
const max_energy : int = 100

var hunt_satiety : int = 20
var wander_time = [8, 12, 16, 24]
export var age : int = 0
var velocity := Vector2.ZERO
var speed := 32.0
var close_enough_distance := 6.0
var random_number = 1000
var interactable := false
var points = 0

export var satiety : int = 100
export var energy : int = max_energy
export var happiness : int = 100
#var sleep_energy : int = 10
export(int, 1, 20) var timer_amount : int = 1
export(int, 1, 20) var stat_incdec : int = 1
onready var sprout_scene = get_parent().sprout_scene
export(PackedScene) var skeleton_scene

signal death

#onready var area_extents = $Area2D/CollisionShape2D.

func _ready():
	Auto.set_debug_visible()
#	if not Auto.debug_view:
#		get_tree().get_nodes_in_group("stat")
	randomize()
	if $Sprite.modulate == Color.white:
		$Sprite.modulate = colors[randi() % colors.size()]
	self.add_to_group("mook")
	self.add_to_group("gobbo")
	$WanderTimer.wait_time = wander_time[randi() % wander_time.size()]
#	$Target.position = $"../debugvector".position
	$Target.position = position
	for t in get_children():
		if t is Timer:
			t.wait_time = timer_amount
	
func _draw():
	if Auto.debug_view == true:
#		if can_hunt():
#			if !get_tree().get_nodes_in_group("food").empty():
#				draw_circle(to_local(find_position_of_closest("food")), 5, Color.yellow)
#			if !get_tree().get_nodes_in_group("mook").empty():
#				draw_circle(to_local(find_position_of_closest("mook")), 5, Color.orange)
#			if !get_tree().get_nodes_in_group("goblin").empty():
#				draw_circle(to_local(find_position_of_closest("goblin")), 5, Color.green)
		draw_line(to_local(position), to_local($Target.position), Color.red, 1)
		draw_circle(to_local($Target.position), 4, Color.blue)
	
#	draw_circle(to_local(position), 2, Color.green)
#	draw_circle(position, 4, Color.magenta)
#	draw_circle(global_position, 4, Color.purple)

func _process(delta):
	update()

func _physics_process(delta):
#	print($WanderTimer.time_left as String)
	
	$"%StatSatiety".text = satiety as String
	$"%StatAge".text = age as String
	$"%StatEnergy".text = energy as String
	$"%StatBoredom".text = happiness as String
	$"%StatID".text = get_instance_id() as String
	
	if can_hunt():
		mission = Mission.HUNT	
	elif happiness <= 20:
		mission = Mission.BORED 
	if mission != Mission.WANDER:
		$WanderTimer.stop()
	if mission != Mission.DEAD or mission != Mission.SLEEP:
		pass
	if energy <= 1:
		mission = Mission.SLEEP

	
	
	match mission:
		Mission.DEBUG:
			die()
			mission = Mission.DEAD
		Mission.DEAD:
			print($PostDeathTimer.time_left)
#			if $PostDeathTimer.is_stopped():
#				$PostDeathTimer.start()
		Mission.JUST_SPAWNED: 
			$Target.position = position
		Mission.IDLE: 
			if not get_tree().get_nodes_in_group("sprout").empty():
				if find_closest_node("sprout").age > 48:
					mission = Mission.PLUCK
			
		Mission.WANDER:
			if $WanderTimer.is_stopped():
				$WanderTimer.start()
			move()
			# if position.distance_to($Target.position) < 5:
			# 	mission = Mission.IDLE
		Mission.BORED:
			move_to(find_closest_node("mook").position)
		Mission.GOTO: {}
		Mission.HUNT: 
			var group
			var food_available : bool = true
			if not get_tree().get_nodes_in_group("food").empty():
				group = "food"
			elif not get_tree().get_nodes_in_group("sprout").empty():
				group = "sprout"
			elif not get_tree().get_nodes_in_group("ling").empty():
				group = "ling"
			elif not get_tree().get_nodes_in_group("goblin").empty():
				group = "gobbo"
			else:
				food_available = false
				
			if food_available:
				var meal_node = find_closest_node(group)
				if can_hunt():
					move_to(meal_node.position)
					if position.distance_to(meal_node.position) < close_enough_distance:
						eat(meal_node)
						mission = Mission.IDLE
		Mission.SLEEP: 
			if $Sprite.rotation_degrees != 90:
				$Sprite.rotation_degrees = 90
			if energy >= max_energy:
				mission = Mission.IDLE
				$Sprite.rotation_degrees = 0
		Mission.PLUCK:
				if not get_tree().get_nodes_in_group("sprout").empty():
					var targ = find_closest_node("sprout")
					move_to(targ.position)
					if position.distance_to(targ.position) < 16:
						pluck(targ)
						mission = Mission.IDLE
	
	if interactable:
		if Input.is_action_pressed("right_click"):
			points += 50 * delta
			Auto.mana -= 50 * delta
			if points > 200:
				turn_into_sprout()
		elif Input.is_action_just_released("right_click"):
			pass

########
# TIMERS
########
func _on_EnergyTimer_timeout():
	if mission != Mission.SLEEP:
		energy -= stat_incdec
	elif mission == Mission.SLEEP:
		energy += stat_incdec * 4
func _on_SatietyTimer_timeout():
	satiety -= stat_incdec
	if satiety == 0:
		die()
func _on_AgeTimer_timeout():
	age += stat_incdec
	if age == grow:
		die()
	if mission == Mission.SLEEP:
		energy += stat_incdec
func _on_WanderTimer_timeout():
#	$Target.position.x = Vector2(,)
	randomize()
#	$Target.position = $"../debugvector".position
#	var r = $AreaCircle/CollisionShape2D.get_shape().radius
#	print(r as String)
	
	random_number = randi() % 50 + 1
	if random_number < 25:
		mission = Mission.IDLE
		return
	
	$Target.position = Vector2(rand_range(16, 352), rand_range(16, 352))

#	$Target.position = to_local(Vector2(rand_range(16, 64), rand_range(16, 64)))
#	$Target.position = to_local(Vector2( rand_range(4, r) , rand_range(4, r) ))
#	print($Target.position as String)
	$WanderTimer.wait_time = wander_time[randi() % wander_time.size()]
	
func _on_BoredomTimer_timeout():
	if mission != Mission.BORED:
		happiness -= 1
	else:
		happiness += 2
	if happiness < 70:
		random_number = randi() % 50 + 1
		print (random_number)
		if random_number == 1:
			mission = Mission.WANDER

#########

func die():
	for t in get_children():
		if t is Timer and not $AgeTimer:
			t.stop()
	mission = Mission.DEAD
	$Sprite.rotation_degrees = -90
	emit_signal("death")
	$sfxDeath.play()
	$PostDeathTimer.start()
	

func move() -> void:
	# https://kidscancode.org/godot_recipes/ai/chase/
	if position.distance_to($Target.position) > close_enough_distance:
		velocity = move_and_slide(position.direction_to($Target.position) * speed)
		
		
func move_to(target):
	$Target.position = target
	move()
		
#func find(group):
#	var options = get_tree().get_nodes_in_group(group)
#	for option in options:
#		var distance = position.distance_to(option.position)
#		print(distance as String)
#		draw_line(to_local(position), option.position, Color.yellow)
		
#func find_and_target(group) -> Vector2:
#	var options = get_tree().get_nodes_in_group(group)
#	for option in options:
#		var distance = position.distance_to(option.position)
#		print(distance as String)
#		draw_line(to_local(position), option.position, Color.yellow)
#	return option.position

# how to find closest?
#func find_position_of_closest(group) -> Vector2:
#
#	var options := get_tree().get_nodes_in_group(group)
#	var targets = []
#	var distances = []
#	var index : int
#	for option in options:
#		var distance = position.distance_to(option.position)
#
##		var target_position = option.position
#		targets.append(option.position)
#		distances.append(distances)
#		var prevdis = distances[index - 1] if not distances.empty() else 999
##		print (prevdis as String)
#		index += 1
#
#	return targets.front()

func find_position_of_closest(group) -> Vector2:
	return find_closest_node(group).position
	
func find_closest_node(group) -> Node2D:

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
	
func find_and_go_to(group):
	if get_tree().get_nodes_in_group(group).empty():
		return 
	$Target.position = find_position_of_closest(group)
	
#func go_to_closest_food():
#	find_and_go_to("food")
	
func eat(meal : Node2D):
	self.satiety += clamp(meal.satiation, 0, 100)
#	self.satiety += meal.satiation
	meal.queue_free()

func pluck(crop : Node2D):
	crop.grow()
	
func can_hunt() -> bool:
	if mission != Mission.DEAD:
		return satiety <= hunt_satiety
	else: return false

	
func grow():
	var skele = skeleton_scene.instance()
	get_parent().add_child(skele)
	skele.position = position
	skele.age = age
	skele.mission = Mission.JUST_SPAWNED
	self.queue_free()
	
func turn_into_sprout():
	var sprout = sprout_scene.instance()
	get_parent().add_child(sprout)
	sprout.position = position
	self.queue_free()


func _on_PostDeathTimer_timeout():
	#$Sprite.texture = load("res://resources/atlas_1bit/bone.atlastex")
	$Sprite.texture = load("res://resources/atlas_1bit/Skeleton.atlastex")
#	$SkeletonTimer.start()

func _on_SkeletonTimer_timeout():
	pass
	#grow()

func _on_AreaClickable_area_entered(area):
	if mission == Mission.DEAD:
		interactable = true
		$"../Hints/HintRMB".modulate = Auto.color_highlight
	#	toggle_stats(true)
func _on_AreaClickable_area_exited(area):
	interactable = false
	$"../Hints/HintRMB".modulate = Auto.color_dim
#	toggle_stats(false)


# none of these work.........
func _on_Goblin_mouse_entered():
	print("works?")
func _on_AreaClickable_mouse_entered():
	print("area")
func _on_AreaCircle_mouse_entered():
	print("circle")

func toggle_stats(boolean):
	if not Auto.debug_view:
		$"%StatID".visible = boolean
		$"%StatAge".visible = boolean
		$"%StatSatiety".visible = boolean
		$"%StatEnergy".visible = boolean
		$"%StatBoredom".visible = boolean
