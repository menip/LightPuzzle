extends Control

export(PackedScene) var game
export(DynamicFont) var font

func _ready():
	layout_levels()

func layout_levels():
	var new_button
	
	for level_number in range(1, Global.FINAL_LEVEL_NUMBER + 1):
		new_button = $SampleButton.duplicate()
		new_button.set_text("%d" % level_number)
		
		if level_number <= int(Global.unlocked_level):
			new_button.connect("pressed", self, "load_level", [level_number])
		else:
			new_button.disabled = true
			
		new_button.show()
		$GridContainer.add_child(new_button)

func load_level(level_number):
	Global.current_level = level_number
	get_tree().change_scene_to(game)