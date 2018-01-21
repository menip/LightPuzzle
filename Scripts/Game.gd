extends Control

export(PackedScene) var player
export(PackedScene) var cell

var level
var cells = {}
var player_instance
var level_area = Rect2(Vector2(), Global.CELL_SIZE * Global.GRID_SIZE)

var color = Global.Colors.WHITE
var direction_choice = Vector2(0,1)

var mouse_position
var offset = Global.CELL_SIZE/2

func _ready():
	setup_level(Global.current_level)
	
	$CanvasLayer/WinLossContainer.hide()
	
	# Setup Direction change signals
	$CanvasLayer/HUD/Directions/Up.connect("pressed", self, "_on_direction_choice_change", [Vector2(0, -1)])
	$CanvasLayer/HUD/Directions/Down.connect("pressed", self, "_on_direction_choice_change", [Vector2(0, 1)])
	$CanvasLayer/HUD/Directions/Left.connect("pressed", self, "_on_direction_choice_change", [Vector2(-1, 0)])
	$CanvasLayer/HUD/Directions/Right.connect("pressed", self, "_on_direction_choice_change", [Vector2(1, 0)])

func _process(delta):
	if player_instance != null and !level_area.has_point(player_instance.position):
		failed()
	
	$Highlight.hide()
	
	# Only concerned with mouse input inside of level grid
	var snapped_position = get_global_mouse_position().snapped(Global.CELL_SIZE) #+ offset #TODO: Ask if bad practice to be creating this new var every process cycle
	if level_area.has_point(snapped_position):
		$Highlight.position = snapped_position
		$Highlight.show()
		
		if Input.is_action_just_pressed("left_click") and !cells.has(snapped_position):
			start_game(snapped_position)

func setup_level(level_name):
	level = level_name
	$CanvasLayer/HUD/LevelName.text = level_name
	load_level(level_name)

func load_level(level_name):
	var level = File.new()
	if !level.file_exists("res://Levels/%s" % level_name):
		print("%s does not exist." % level_name)
		return
	
	level.open("res://Levels/%s" % level_name, File.READ)
	var current_line = {}
	while !level.eof_reached():
		current_line = parse_json(level.get_line())
		
		# TODO: Find better solution
		# Loops currently tries to read line after last, so current_line becomes null. Hack to get around that
		if current_line == null: 
			break
		
		var new_cell = cell.instance()
		new_cell.position = Vector2(current_line["posx"], current_line["posy"]) * Global.CELL_SIZE #+ offset
		new_cell.color = int(current_line["color"])
		new_cell.modifier = int(current_line["modifier"])
		new_cell.flipped = current_line["flipped"]
		
		cells[new_cell.position] = new_cell
		add_child(new_cell)

func _on_direction_choice_change(choice):
	direction_choice = choice

func start_game(spawn_position):
	if player_instance == null:
		player_instance = player.instance()
		player_instance.position = spawn_position 
		player_instance.direction = direction_choice
		player_instance.color = color
		
		player_instance.target_position = spawn_position + direction_choice * Global.CELL_SIZE
		
		add_child(player_instance)
		
		# Connect player signal
		$Player.connect("update_instructions", self, "update_instructions")

func success():
	# Level over, no longer need player to update
	$Player.disconnect("update_instructions", self, "update_instructions")
	Global.current_level = "%03d" % (int(Global.current_level) + 1)
		
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
	var current_level = int(Global.current_level)
	if current_level != Global.FINAL_LEVEL_NUMBER:
		get_tree().reload_current_scene() 
	else:
		get_tree().change_scene("res://Scenes/Credits.tscn")
	
func reload_level():
	get_tree().reload_current_scene()

func _on_MainMenu_pressed():
	get_tree().change_scene("res://Scenes/MainMenu.tscn")