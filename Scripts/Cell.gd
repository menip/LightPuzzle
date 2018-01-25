extends Sprite

var color
var modifier
var flipped = 1

func _ready():	
	update_self()

func update_self():
	modulate = Global.which_color(color)
	texture = load(match_modifier())
	rotation_degrees = 90 if flipped == -1 else 0

func match_modifier():
	match modifier:
		Global.Modifier.ANGLE:			return "res://Assets/Angle.png"
		Global.Modifier.MIRROR: 		return "res://Assets/Mirror.png"
		Global.Modifier.COLOR_SWITCH: 	return "res://Assets/ColorSwitch.png"
		Global.Modifier.DEFAULT: 		return "" # TODO: Hack. Need to update all current levels to not have a default first, then can remove. Sends load errors atm, but no crash _/(`_`)\_
		Global.Modifier.FINAL:			return "res://Assets/Final.png"