extends Control

export(PackedScene) var player
export(PackedScene) var cell

func _ready():
	load_level("Level_01")

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass

func load_level(name):
	var level = File.new()
	if !level.file_exists("res://Levels/%s" % name):
		print("%s does not exist." % name)
		return
	
	level.open("res://Levels/%s" % name, File.READ)
	var current_line = {}
	while !level.eof_reached():
		current_line = parse_json(level.get_line())
		
		# TODO: Find better solution
		# Loops currently tries to read line after last, so current_line becomes null. Hack to get around that
		if current_line == null: 
			break
		
		var new_cell = cell.instance()
		new_cell.position = Vector2(current_line["posx"], current_line["posy"])
		new_cell.color = int(current_line["color"])
		new_cell.modifier = int(current_line["modifier"]) #Why this not work then?
		new_cell.flipped = current_line["flipped"]
		new_cell.final = current_line["final"]
		add_child(new_cell)
		
		print(new_cell.modifier)
	