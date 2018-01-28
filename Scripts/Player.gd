extends Sprite

signal success
signal failed

const SPEED = 164
const POSITION_SNAP_AMOUNT = 2

var color
var direction
var target_position

var current_cell

func _ready():
	modulate = Global.which_color(color)

func _process(delta):
	position += direction * SPEED * delta
	
	# If we are close to desired position, snap to it, and obtain further instructions
	if (position - target_position).length() <= POSITION_SNAP_AMOUNT:
		position = target_position
		update_target_position()
		update_self()

func update_self():
	modulate = Global.which_color(color)

func update_target_position():
	# If player is in square that contains cell
	if current_cell != null:
		# Player only interacts with objects of same color, unless we are on a color switch tile
		if current_cell.modifier == Global.Modifier.FINAL:
			emit_signal("success")
			# NOTE: player is still on this cell, so we will continue hitting this code.
			return
		elif current_cell.modifier == Global.Modifier.COLOR_SWITCH:
			color = current_cell.color
		elif color == current_cell.color:
			match current_cell.modifier:
				Global.Modifier.ANGLE:
					if direction.x != 0:
						direction = Vector2(0, direction.x * -current_cell.flipped)
					elif direction.y !=0:
						direction = Vector2(direction.y * -current_cell.flipped,0)
				Global.Modifier.MIRROR: 
					# If player hits mirror at it's side, level is failed and player shatters
					#TODO: Set this up as either a or b equals c
					if abs(direction.x) == current_cell.flipped or -abs(direction.y) == current_cell.flipped: # flipped is int: 1 when not flipped, -1 when flipped
						emit_signal("failed")
						return
					direction *= -1
	target_position = position + direction * Global.CELL_SIZE 

func _on_Area2D_area_entered( area ):
	current_cell = area.get_parent()

func _on_Area2D_area_exited( area ):
	current_cell = null
