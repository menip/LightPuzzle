extends Area2D

enum Modifier {ANGLE, MIRROR, COLOR_SWITCH, TELLEPORT, NULL}
export (preload("res://Scripts/Global.gd").Colors) var color = preload("res://Scripts/Global.gd").Colors.WHITE
export (Modifier) var modifier
export(Vector2) var teleport_location
export(bool) var flipped = false
export(bool) var final = false #TODO: Implement this logic

func _ready():
	# This is a hack and I don't like it. Seems like export (int, -1, 1, 2) doesn't work correctly: bug
	flipped = -1 if flipped else 1
	
	$CellSprite.modulate = Global.which_color(color)
	
	if modifier != Modifier.NULL:
		$CellSprite.get_node("ModifierSprite").texture = load(match_modifier())
		if flipped == -1:
			$CellSprite.get_node("ModifierSprite").rotation_degrees = 90 

func match_modifier():
	match modifier:
		ANGLE: 			return "res://Art/Angle.png"
		MIRROR: 		return "res://Art/Mirror.png"
		COLOR_SWITCH: 	return "res://Art/ColorSwitch.png"
		TELLEPORT: 		return "res://Art/Telleport.png"

func update_instructions(player):
	var direction = player.direction
	var target_position = player.target_position
	
	if player.color == color:
		match modifier:
			Modifier.ANGLE:
				if direction.x != 0:
					direction = Vector2(0, direction.x * flipped)
				elif direction.y !=0:
					direction = Vector2(-direction.y * flipped,0)
			Modifier.MIRROR: 
				direction *= -1
			Modifier.COLOR_SWITCH:
				player.color = color 
			Modifier.TELLEPORT:
				 player.position = teleport_location.position
	
	player.direction = direction
	if modifier != Modifier.TELLEPORT:
		# Set next target poisition at next cell. Multiply by 64 because that is texture size
		player.target_position = position + direction * 64