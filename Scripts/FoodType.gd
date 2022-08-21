extends Node

class_name FoodType

var satiation : int
var sprite : Texture

#ctor
func _init(sat:int = 30):
	satiation = sat
