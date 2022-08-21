extends Node2D

var food = FoodType.new(35)
var satiation := 0.0
#var carrot = FoodType.new(35)
#var meat = FoodType.new(80)
#const xxx := {
#	carrot = preload("res://resources/atlas_1bit/carrot.atlastex"),
#	"meat": preload("res://resources/atlas_1bit/meat.atlastex"),
#	}
export(String, "carrot", "meat") var food_type
var interactable : bool = false
var alchemized : bool = false
var alchemy_progress_percentage : float = 0
var modulate_num : float

func _ready():
	$StatSat.visible = false
	position = position
	add_to_group("food")
	match food_type:
		"carrot":
			food.satiation = 35
			$Sprite.texture = load("res://resources/atlas_1bit/carrot.atlastex")
		"meat":
			food.satiation = 80
			$Sprite.texture = load("res://resources/atlas_1bit/meat.atlastex")
	satiation = food.satiation
	
func _physics_process(delta):
	$StatSat.text = satiation as String
	if satiation < 80 and satiation > 35:
		alchemy_progress_percentage = satiation / 80
#		print("pct " + alchemy_progress_percentage as String)
		modulate_num = alchemy_progress_percentage + 1
#		print("mod" + modulate_num as String)
		$Sprite.modulate = Color(modulate_num, modulate_num, modulate_num)
	if satiation >= 80 and not alchemized:
		$Sprite.modulate = Color.white
		$Sprite.texture = load("res://resources/atlas_1bit/meat.atlastex")
		Input.action_release("right_click")
		$sfxAlchemy.play()
		alchemized = true
		interactable = false
	if not interactable:
		$AnimationPlayer.play("RESET")
	if interactable:
		if Input.is_action_pressed("right_click"):
			$AnimationPlayer.play("alchemize")
			$AnimationPlayer.playback_speed =\
					alchemy_progress_percentage\
					if alchemy_progress_percentage < .92\
					else alchemy_progress_percentage * 2
			satiation += 4.5 * delta
			Auto.mana -= 50 * delta
		elif Input.is_action_just_released("right_click"):
			$AnimationPlayer.play("RESET")



func _on_Area2D_area_entered(area):
	get_parent().get_node("Hints/HintRMB").modulate = Auto.color_highlight
	$AnimationPlayer.play("wiggle")
	interactable = true
func _on_Area2D_area_exited(area):
	get_parent().get_node("Hints/HintRMB").modulate = Auto.color_dim
	$AnimationPlayer.play("RESET")
	interactable = false
