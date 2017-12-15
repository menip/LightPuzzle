extends Area2D

enum Modifier {ANGLE, MIRROR,COLOR_SWITCH, TELLEPORT}
#export (Global.Colors) var color 
#export (Modifier) var modifier
export(int, -1, 1, 2) var flipped = 1
export(Vector2) var teleport_position

##############TODO: REMOVE. TESTING ONLY########
#var color = Global.Colors.WHITE
var modifier = Modifier.COLOR_SWITCH
################################################

func update_instructions(player):
	var direction = player.direction
	var target_position = player.target_position
	
	if player.color == color:
		match modifier:
			Modifier.ANGLE:
				if direction.x != 0:
					direction = Vector2(0, direction.x * flipped)
				elif direction.y !=0:
					# TODO: Make sure that I can just have negative sign. Might need to multiple by -1
					direction = Vector2(-direction.y * flipped,0)
			Modifier.MIRROR: 
				direction *= -1
			Modifier.COLOR_SWITCH:
				player.color = color 
			Modifier.TELLEPORT:
				 player.position = teleport_position
	
	player.direction = direction
	if modifier != Modifier.TELLEPORT:
		# Set next target poisition at next cell. Multiply by 64 because that is texture size
		player.target_position = position + direction * 64

func _ready():
	$CellSprite.modulate = Global.which_color(Global.Colors.WHITE) ##############TODO: CHANGE
	
	var modifierTexture
	match modifier:
		Modifier.ANGLE: modifierTexture = load("res://Art/Angle.png")
		Modifier.MIRROR: modifierTexture = load("res://Art/Mirror.png")
		Modifier.COLOR_SWITCH: modifierTexture = load("res://Art/ColorSwitch.png")
		Modifier.TELLEPORT: modifierTexture = load("res://Art/Telleport.png")
	$CellSprite.get_node("ModifierSprite").texture = modifierTexture