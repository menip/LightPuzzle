extends Area2D

export (preload("res://Scripts/Global.gd").Colors) var color = preload("res://Scripts/Global.gd").Colors.WHITE
export (preload("res://Scripts/Global.gd").Modifier) var modifier = preload("res://Scripts/Global.gd").Modifier.DEFAULT
export(Vector2) var teleport_location
export(bool) var flipped = false
export(bool) var final = false #TODO: Implement this logic

func _ready():
	# This is a hack and I don't like it. Seems like export (int, -1, 1, 2) doesn't work correctly: bug
	flipped = -1 if flipped else 1
	
	#########TODO: REMOVE##################
	modifier = Global.Modifier.DEFAULT
	####################################
	
	update_self()

func update_instructions(player):
	var direction = player.direction
	var target_position = player.target_position
	
	if player.color == color:
		match modifier:
			Global.Modifier.ANGLE:
				if direction.x != 0:
					direction = Vector2(0, direction.x * flipped)
				elif direction.y !=0:
					direction = Vector2(-direction.y * flipped,0)
			Global.Modifier.MIRROR: 		direction *= -1
			Global.Modifier.COLOR_SWITCH:	player.color = color 
			Global.Modifier.TELLEPORT:		player.position = teleport_location.position
	
	player.direction = direction
	if modifier != Global.Modifier.TELLEPORT:
		# Set next target poisition at next cell. Multiply by 64 because that is texture size
		player.target_position = position + direction * Global.CELL_SIZE

func update_self():
	if final: 
		color = Global.Colors.FINAL

	$CellSprite.modulate = Global.which_color(color)
	$CellSprite.get_node("ModifierSprite").texture = load(match_modifier())
	$CellSprite.get_node("ModifierSprite").rotation_degrees = 90 if flipped == -1 else 0

func match_modifier():
	match modifier:
		Global.Modifier.ANGLE: 			return "res://Art/Angle.png"
		Global.Modifier.MIRROR: 		return "res://Art/Mirror.png"
		Global.Modifier.COLOR_SWITCH: 	return "res://Art/ColorSwitch.png"
		Global.Modifier.TELLEPORT: 		return "res://Art/Telleport.png"
		Global.Modifier.DEFAULT: 		return "res://Art/Cell.png"