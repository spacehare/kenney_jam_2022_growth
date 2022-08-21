extends Node

const STAGE_1 := 60
const STAGE_2 := 120
const STAGE_3 := 240
const STAGE_4 := 400

var mana : float = 1000

var debug_view : bool = true

const color_dim := Color(0.227451, 0.227451, 0.227451)
const color_highlight := Color.burlywood

var sproutling_hint := false
var carrot_hint := false

#var lmb_highlight := false
#var rmb_highlight := false

func set_debug_visible():
	var stats = get_tree().get_nodes_in_group("stat") + get_tree().get_nodes_in_group("debug")
	for stat in stats:
		stat.visible = Auto.debug_view
		
func _process(delta):
	if mana > 1000:
		mana = clamp(mana, 0, 1000)
	if (not Input.is_action_pressed("click") or not Input.is_action_pressed("right_click")) and not mana > 1000:
		mana += 6 * delta

#onready var cursor_position := get_viewport().get_mouse_position()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

#func _input(event):
#	if event is InputEventMouseButton:
#		print("Mouse Click/Unclick at: ", event.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
