extends Area2D

var color
var modifier
var flipped = 1

func _ready():	
	update_self()

func update_self():
	$CellSprite.modulate = Global.which_color(color)
	$CellSprite.get_node("ModifierSprite").texture = load(match_modifier())
	$CellSprite.get_node("ModifierSprite").rotation_degrees = 90 if flipped == -1 else 0

func match_modifier():
	match modifier:
		Global.Modifier.ANGLE:			return "res://Assets/Angle.png"
		Global.Modifier.MIRROR: 		return "res://Assets/Mirror.png"
		Global.Modifier.COLOR_SWITCH: 	return "res://Assets/ColorSwitch.png"
		Global.Modifier.DEFAULT: 		return "res://Assets/Cell.png"
		Global.Modifier.FINAL:			return "res://Assets/Final.png"