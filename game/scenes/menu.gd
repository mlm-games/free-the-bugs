extends Control


func _ready() -> void:
	%PlayButton.grab_focus()
	
	%PlayButton.pressed.connect(Transitions.change_scene_with_transition_packed.bind(C.Scenes.FirstLevelScene))
	%SettingsButton.pressed.connect(add_child.bind(C.Scenes.SettingsScene.instantiate()))
	%ExitButton.pressed.connect(_on_exit_button_pressed)
	%CreditsButton.pressed.connect(Transitions.change_scene_with_transition_packed.bind(C.Scenes.CreditsScene))
	
	AudioM



func _on_exit_button_pressed() -> void:
	# gently shutdown the game
	Transitions.transition()
	await Transitions.transition_player.animation_finished
	get_tree().quit()
