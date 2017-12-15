extends Node

enum Colors {WHITE, RED, BLUE}

func which_color(color):
	match color:
		WHITE:	return Color(1,1,1)
		RED:	return Color(1,0,0)
		BLUE:	return Color(0,0,1)