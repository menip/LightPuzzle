extends Control

export(PackedScene) var LevelSelect

func _on_Start_pressed():
	get_tree().change_scene_to(LevelSelect)
	
func _on_Credits_pressed():
	$CreditsDialog.show()