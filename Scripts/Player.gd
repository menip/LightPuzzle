extends Area2D

signal update_instructions

export(int) var SPEED = 64
export(int) var POSITION_SNAP_AMOUNT = 5

var color
var direction
var target_position
var current_square

func _ready():
	$Sprite.modulate = Global.which_color(color)

func _process(delta):
	position += direction * SPEED * delta
	
	# If we are close to desired position, snap to it, and obtain further instructions
	if (position - target_position).length() <= POSITION_SNAP_AMOUNT:
		position = target_position
		emit_signal("update_instructions")
		update_self()

func update_self():
	$Sprite.modulate = Global.which_color(color)