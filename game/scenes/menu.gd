extends Control

func _ready() -> void:
	%PlayButton.grab_focus()
	
	%PlayButton.pressed.connect(LevelManager.instance.start_game)
	%SettingsButton.pressed.connect(Transitions.instantiate_scene_on_top.bind(C.SCENE_PATHS.SETTINGS_SCENE_PATH))
	%ExitButton.pressed.connect(_on_exit_button_pressed)
	%CreditsButton.pressed.connect(Transitions.change_scene_with_transition.bind(C.SCENE_PATHS.CREDITS_SCENE_PATH))
	
	



func _on_exit_button_pressed() -> void:
	# gently shutdown the game
	Transitions.transition()
	await Transitions.transition_player.animation_finished
	get_tree().quit()
