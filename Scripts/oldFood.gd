extends Node

var xyz : FoodType

# TODO: better way to do this ???????????
# generic food clasS ? idk how to implement classes in godot :(
enum food_enum {CARROT, MEAT}
export(food_enum) var food_type
var satiation
const sprite := {
	carrot = preload("res://resources/atlas_1bit/carrot.atlastex"),
	"meat": preload("res://resources/atlas_1bit/meat.atlastex"),
	}
var food_texture = sprite.meat




func _ready():
	match food_type:
		food_enum.CARROT:
			$Sprite.texture = sprite.carrot
		food_enum.MEAT:
			$Sprite.texture = sprite.meat
	add_to_group("food")
	
