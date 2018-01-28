extends Control

export(PackedScene) var player
export(PackedScene) var cell

var level # TODO: Need consistency with level_number in other parts of the code
var cells = {}
var player_instance
var level_area = Rect2(Vector2(), Global.CELL_SIZE * Global.GRID_SIZE)

var mouse_position

var direction_choice = Vector2(0,1)

func _ready():
	setup_level(Global.current_level)
	
	$CanvasLayer/WinLossContainer.hide()

func _process(delta):
	if player_instance != null and !level_area.has_point(player_instance.position):
		failed()
	
	# TODO: Need to have a check for whether game is currently active or not, so that we don't keep checking after game started
	# Only concerned with mouse input inside of level grid
	var snapped_position = get_global_mouse_position().snapped(Global.CELL_SIZE) # TODO: I should probably not be creating a new Vector2 every time
	if level_area.has_point(snapped_position):
		if Input.is_action_just_pressed("left_click") and !cells.has(snapped_position):
			start_game(snapped_position)

func setup_level(level_number):
	level = level_number
	$CanvasLayer/HUD/LevelName.text = String(level_number)
	load_level(level_number)

# TODO: This will be greatly simplified after we switch to scenes for level storage
func load_level(level_number):
	var level = File.new()
	if !level.file_exists("res://Levels/%d" % level_number):
		print("%d does not exist." % level_number)
		return
	
	level.open("res://Levels/%d" % level_number, File.READ)
	var current_line = {}
	while !level.eof_reached():
		current_line = parse_json(level.get_line())
		
		# TODO: Find better solution
		# Loops currently tries to read line after last, so current_line becomes null. Hack to get around that
		if current_line == null: 
			break
		
		var new_cell = cell.instance()
		new_cell.position = Vector2(current_line["posx"], current_line["posy"]) * Global.CELL_SIZE
		new_cell.color = int(current_line["color"])
		new_cell.modifier = int(current_line["modifier"])
		new_cell.flipped = current_line["flipped"]
		
		cells[new_cell.position] = new_cell
		$Level.add_child(new_cell)

func _on_direction_choice_change(choice):
	direction_choice = choice

func start_game(spawn_position):
	if player_instance == null: # This check needs to be done in process above
		player_instance = player.instance()
		player_instance.position = spawn_position 
		player_instance.direction = direction_choice
		player_instance.color = Global.Colors.WHITE
		
		player_instance.target_position = spawn_position + direction_choice * Global.CELL_SIZE
		
		add_child(player_instance)
		
		# Connect player signal
		$Player.connect("update_instructions", self, "update_instructions")

func success():
	# Level over, no longer need player to update
	$Player.disconnect("update_instructions", self, "update_instructions") # TODO: Kinda hackish, need to have boolean controlling game state
	
	# Check if player unlocked a new level
	if Global.current_level == Global.unlocked_level:
		Global.unlocked_level += 1
	Global.current_level += 1
		
	$CanvasLayer/WinLossContainer.show()
	$CanvasLayer/WinLossContainer/WinLossText.text = "Success!"
	$CanvasLayer/WinLossContainer/WinLossButton.text = "Next"
	
	$CanvasLayer/WinLossContainer/WinLossButton.connect("pressed", self, "next_level")

func failed():
	remove_child(player_instance)
	player_instance = null
	
	$CanvasLayer/WinLossContainer.show()
	$CanvasLayer/WinLossContainer/WinLossText.text = "Failed"
	$CanvasLayer/WinLossContainer/WinLossButton.text = "Retry"
	
	$CanvasLayer/WinLossContainer/WinLossButton.connect("pressed", self, "reload_level")

# TODO: This needs to be made better, probably moved outside of Game class
func update_instructions():
	var direction = player_instance.direction
	var target_position = player_instance.target_position
	
	# If player is in square that contains cell
	if cells.has(player_instance.position):
		var current_cell = cells[player_instance.position]
		
		# Player only interacts with objects of same color, unless we are on a color switch tile
		if current_cell.modifier == Global.Modifier.FINAL:
			success()
			# NOTE: player is still on this cell, so we will continue hitting this code.
			return
		elif current_cell.modifier == Global.Modifier.COLOR_SWITCH:
			player_instance.color = current_cell.color
		elif player_instance.color == current_cell.color:
			match current_cell.modifier:
				Global.Modifier.ANGLE:
					if direction.x != 0:
						direction = Vector2(0, direction.x * -current_cell.flipped)
					elif direction.y !=0:
						direction = Vector2(-direction.y * current_cell.flipped,0)
				Global.Modifier.MIRROR: 
					# If player hits mirror at it's side, level is failed and player shatters
					if abs(player_instance.direction.x) == current_cell.flipped or -abs(player_instance.direction.y) == current_cell.flipped: # flipped is int: 1 when not flipped, -1 when flipped
						failed()
						return
					direction *= -1
		
		player_instance.direction = direction
	
	# Set next target poisition at next square.
	player_instance.target_position = player_instance.position + player_instance.direction * Global.CELL_SIZE
	
func next_level():
	# Load next level if there is one. If player beat last level, roll credits!
	if int(Global.current_level) <= Global.FINAL_LEVEL_NUMBER:
		reload_level() 
	else:
		get_tree().change_scene("res://Scenes/Credits.tscn")
	
func reload_level():
	get_tree().reload_current_scene()

func _on_MainMenu_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")