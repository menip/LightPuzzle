extends Area2D

export(int) var SPEED = 10
export(int) var POSITION_SNAP_AMOUNT = 5

# Player only interacts with objects of same color
export var color = Global.Colors.WHITE

var direction
var target_position
var current_square

func set_color(color):
	match color:
		WHITE:	$Sprite.modulate = Color(1,1,1)
		RED:	$Sprite.modulate = Color(1,0,0)
		BLUE:	$Sprite.modulate = Color(0,0,1)

func _ready():
	pass

func _process(delta):
	position += direction * SPEED * delta
	
	# If we are close to desired position, snap to it, and obtain further instructions
	if (position - target_position).length() <= POSITION_SNAP_AMOUNT:
		position = target_position
		current_square.update_instructions(self)


func _on_Player_area_entered( area ):
	current_square = area