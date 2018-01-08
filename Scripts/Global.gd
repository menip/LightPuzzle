extends Node

const CELL_SIZE = Vector2(64, 64)
const GRID_SIZE = Vector2(10, 10)
enum Colors {WHITE, RED, BLUE}
enum Modifier {ANGLE, MIRROR, COLOR_SWITCH, DEFAULT, FINAL}

# This is probably bad way to do this, but it works
const FINAL_LEVEL_NUMBER = 5
var current_level = "000"

func which_color(color):
	match color:
		WHITE:	return Color(1,1,1)
		RED:	return Color(.96,.28,.28)
		BLUE:	return Color(0,0,1)