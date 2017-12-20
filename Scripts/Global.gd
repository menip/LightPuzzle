extends Node

const CELL_SIZE = Vector2(64, 64)
const GRID_SIZE = Vector2(10, 10)
enum Colors {WHITE, RED, BLUE, FINAL}
enum Modifier {ANGLE, MIRROR, COLOR_SWITCH, TELLEPORT, DEFAULT}

func which_color(color):
	match color:
		WHITE:	return Color(1,1,1)
		RED:	return Color(.96,.28,.28)
		BLUE:	return Color(0,0,1)
		FINAL: 	return Color(.28, .96, .28)