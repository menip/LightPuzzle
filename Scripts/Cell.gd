extends Area2D

export (preload("res://Scripts/Global.gd").Colors) var color = preload("res://Scripts/Global.gd").Colors.WHITE
export (preload("res://Scripts/Global.gd").Modifier) var modifier = preload("res://Scripts/Global.gd").Modifier.DEFAULT
export(Vector2) var teleport_location
export(bool) var flipped 

func _ready():
	# This is a hack and I don't like it. Seems like export (int, -1, 1, 2) doesn't work correctly: bug
	#flipped = -1 if flipped else 1
	
	update_self()

func update_self():
	$CellSprite.modulate = Global.which_color(color)
	$CellSprite.get_node("ModifierSprite").texture = load(match_modifier())
	$CellSprite.get_node("ModifierSprite").rotation_degrees = 90 if flipped == -1 else 0

func match_modifier():
	match modifier:
		Global.Modifier.ANGLE:			return "res://Art/Angle.png"
		Global.Modifier.MIRROR: 		return "res://Art/Mirror.png"
		Global.Modifier.COLOR_SWITCH: 	return "res://Art/ColorSwitch.png"
		Global.Modifier.TELLEPORT: 		return "res://Art/Telleport.png"
		Global.Modifier.DEFAULT: 		return "res://Art/Cell.png"
		Global.Modifier.FINAL:			return "res://Art/Final.png"