extends Control

export(PackedScene) var cell

var color = Global.Colors.WHITE
var modifier = Global.Modifier.DEFAULT
var name

var anchor
var mouse_position
var current_cell_position = Vector2()
var rect_space

var cells = {}

func _ready():
	anchor = $Position2D.position
	rect_space = Rect2(Vector2(), Global.CELL_SIZE * Global.GRID_SIZE)
	$Highlight.hide()
	
	# Setup right click menu
	$PopupMenu.add_item("Flip")
	
	# Connect color change signals
	$GridContainer/ColorsButtons/White.connect("pressed", self, "_on_color_change", [Global.Colors.WHITE])
	$GridContainer/ColorsButtons/Red.connect("pressed", self, "_on_color_change", [Global.Colors.RED])
	$GridContainer/ColorsButtons/Blue.connect("pressed", self, "_on_color_change", [Global.Colors.BLUE])
	
	# Connect modifier change signals
	$GridContainer/CellModifierButtons/Cell.connect("pressed", self, "_on_modifier_change", [Global.Modifier.DEFAULT])
	$GridContainer/CellModifierButtons/Angled.connect("pressed", self, "_on_modifier_change", [Global.Modifier.ANGLE])
	$GridContainer/CellModifierButtons/Mirror.connect("pressed", self, "_on_modifier_change", [Global.Modifier.MIRROR])
	$GridContainer/CellModifierButtons/ColorSwitch.connect("pressed", self, "_on_modifier_change", [Global.Modifier.COLOR_SWITCH])
	$GridContainer/CellModifierButtons/Final.connect("pressed", self, "_on_modifier_change", [Global.Modifier.FINAL])

func _process(delta):
	$Highlight.hide()
	mouse_position = get_global_mouse_position()
	
	# Only concerned with mouse input inside of level grid
	var curr_cell_pos = mouse_position.snapped(Global.CELL_SIZE) + Global.CELL_SIZE/2
	if rect_space.has_point(curr_cell_pos):
		current_cell_position = curr_cell_pos
		$Highlight.position = current_cell_position
		$Highlight.show()
		
		if Input.is_mouse_button_pressed(BUTTON_LEFT):
			if cells.has(current_cell_position):
				cells[current_cell_position].modifier = modifier
				cells[current_cell_position].color = color
			else:
				var new_cell = cell.instance()
				new_cell.position = current_cell_position
				new_cell.color = color
				new_cell.modifier = modifier
				new_cell.flipped = 1
				
				add_child(new_cell)
				cells[current_cell_position] = new_cell
				
			# Make sure we aren't tinting final sprite
			if modifier == Global.Modifier.FINAL:
				cells[current_cell_position].color = Global.Colors.WHITE
				
			# Updated cell values, now let cell update itself
			cells[current_cell_position].update_self()
			
		elif cells.has(current_cell_position):
			if Input.is_mouse_button_pressed(BUTTON_RIGHT):
				$PopupMenu.rect_position = mouse_position
				$PopupMenu.show()
			elif Input.is_key_pressed(KEY_E):
				# Erase cell
				remove_child(cells[current_cell_position])
				cells.erase(current_cell_position)

func _on_color_change(new_color):
	color = new_color

func _on_modifier_change(new_modifier):
	modifier = new_modifier

func _on_PopupMenu_id_pressed( ID ):
	# Is it possible to match by item, rather than index?
	match ID:
		0: cells[current_cell_position].flipped *= -1
	cells[current_cell_position].update_self()

func _on_SaveButton_pressed():
	var level_save = File.new()
	level_save.open("res://Levels/%s" % $GridContainer/Save/LevelName.text, File.WRITE)
	
	for i in cells:
		var save_dict = {
			"posx"		: int(cells[i].position.x / Global.CELL_SIZE.x), 
			"posy"		: int(cells[i].position.y / Global.CELL_SIZE.y),
			"color"		: cells[i].color, 
			"modifier"	: cells[i].modifier, 
			"flipped"	: cells[i].flipped
			}
		# Convert dictionary to string, parse that as JSON, and store the result in file
		level_save.store_line(to_json(save_dict))
	
	level_save.close()
	
	
	