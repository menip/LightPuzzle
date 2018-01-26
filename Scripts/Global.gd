extends Node

const CELL_SIZE = Vector2(64, 64)
const GRID_SIZE = Vector2(10, 10)
const LEVEL_OFFSET = Vector2(32, 32)

enum Colors {WHITE, RED, BLUE}
enum Modifier {ANGLE, MIRROR, COLOR_SWITCH, DEFAULT, FINAL}

# This is probably bad way to do this, but it works
const FINAL_LEVEL_NUMBER = 11
var current_level = 1
var unlocked_level = 1

func which_color(color):
	match color:
		WHITE:	return Color(1,1,1)
		RED:	return Color(.96,.28,.28)
		BLUE:	return Color(0,0,1)
		
func which_modifier_texture(modifier):
	match modifier:
		Global.Modifier.ANGLE:			return load("res://Assets/Angle.png")
		Global.Modifier.MIRROR: 		return load("res://Assets/Mirror.png")
		Global.Modifier.COLOR_SWITCH: 	return load("res://Assets/ColorSwitch.png")
		Global.Modifier.DEFAULT: 		return null # TODO: Hack. Need to update all current levels to not have a default first, then can remove. no crash _/(`_`)\_
		Global.Modifier.FINAL:			return load("res://Assets/Final.png")