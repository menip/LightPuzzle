extends Control

export(PackedScene) var game

func _ready():
	layout_levels()

func layout_levels():
	var new_button
	var level_name
	for i in range(Global.FINAL_LEVEL_NUMBER + 1):
		level_name = "%03d" % i
		new_button = Button.new()
		new_button.set_text(level_name)
		new_button.connect("pressed", self, "load_level", [level_name])
		$GridContainer.add_child(new_button)

func load_level(name):
	Global.current_level = name
	get_tree().change_scene_to(game)