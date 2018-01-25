extends Sprite

signal update_instructions

const SPEED = 128
const POSITION_SNAP_AMOUNT = 5

var color
var direction
var target_position

func _ready():
	modulate = Global.which_color(color)

func _process(delta):
	position += direction * SPEED * delta
	
	# If we are close to desired position, snap to it, and obtain further instructions
	if (position - target_position).length() <= POSITION_SNAP_AMOUNT:
		position = target_position
		emit_signal("update_instructions")
		update_self()

func update_self():
	modulate = Global.which_color(color)