extends Control

export(PackedScene) var game
export(DynamicFont) var font

func _ready():
	layout_levels()

func layout_levels():
	var new_button
	var level_name
	for i in range(Global.FINAL_LEVEL_NUMBER + 1):
		level_name = "%03d" % i
		new_button = $SampleButton.duplicate()
		new_button.set_text("%d" % i)
		
		if i <= int(Global.current_level):
			new_button.connect("pressed", self, "load_level", [level_name])
		else:
			new_button.disabled = true
		new_button.show()
		$GridContainer.add_child(new_button)

func load_level(level_name):
	Global.current_level = level_name
	get_tree().change_scene_to(game)