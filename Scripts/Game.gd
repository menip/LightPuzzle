extends Control

export(PackedScene) var player
export(PackedScene) var cell

var level # TODO: Need consistency with level_number in other parts of the code
var cells = {}
var player_instance
var level_area = Rect2(Vector2(), Global.CELL_SIZE * Global.GRID_SIZE)

var mouse_position

var direction_choice = Vector2(0,1)

var game_played = false

func _ready():
	setup_level(Global.current_level)
	
	$CanvasLayer/WinLossContainer.hide()

func _process(delta):
	# If player is alive and goes outside level bounds, game over
	if player_instance != null and !level_area.has_point(player_instance.position):
		failed()
	
	if not game_played:
		# Only concerned with mouse input inside of level grid
		var snapped_position = get_global_mouse_position().snapped(Global.CELL_SIZE) # TODO: I should probably not be creating a new Vector2 every time
		if level_area.has_point(snapped_position):
			if Input.is_action_just_pressed("left_click") and !cells.has(snapped_position):
				start_game(snapped_position)

func setup_level(level_number):
	level = level_number
	$CanvasLayer/HUD/LevelName.text = String(level_number)
	load_level(level_number)

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
		new_cell.color = int(current_line["color"]) # TODO: Should we use modulate values instead of a color var?
		new_cell.modifier = int(current_line["modifier"])
		new_cell.flipped = current_line["flipped"]
		
		cells[new_cell.position] = new_cell
		$Level.add_child(new_cell)

func _on_direction_choice_change(choice):
	direction_choice = choice

func start_game(spawn_position):
	player_instance = player.instance()
	player_instance.position = spawn_position 
	player_instance.direction = direction_choice
	player_instance.color = Global.Colors.WHITE
	
	player_instance.target_position = spawn_position + direction_choice * Global.CELL_SIZE
	
	add_child(player_instance)
	
	# Connect player signal
	$Player.connect("success", self, "success")
	$Player.connect("failed", self, "failed")

func success():
	game_played = true
	remove_child(player_instance)
	
	# Check if player unlocked a new level
	if Global.current_level == Global.unlocked_level:
		Global.unlocked_level += 1
	Global.current_level += 1
		
	$CanvasLayer/WinLossContainer.show()
	$CanvasLayer/WinLossContainer/WinLossText.text = "Success!"
	$CanvasLayer/WinLossContainer/WinLossButton.text = "Next"
	
	$CanvasLayer/WinLossContainer/WinLossButton.connect("pressed", self, "next_level")

func failed():
	game_played = true
	remove_child(player_instance)
	
	$CanvasLayer/WinLossContainer.show()
	$CanvasLayer/WinLossContainer/WinLossText.text = "Failed"
	$CanvasLayer/WinLossContainer/WinLossButton.text = "Retry"
	
	$CanvasLayer/WinLossContainer/WinLossButton.connect("pressed", self, "reload_level")

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