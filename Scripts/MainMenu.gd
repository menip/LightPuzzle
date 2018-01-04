extends Control

func _on_Start_pressed():
	get_tree().change_scene("res://Scenes/LevelSelect.tscn")
	
func _on_Credits_pressed():
	$Name.hide()
	$Buttons.hide()
	$CreditsScreen.show()



func _on_CloseButton_pressed():
	$Name.show()
	$Buttons.show()
	$CreditsScreen.hide()
