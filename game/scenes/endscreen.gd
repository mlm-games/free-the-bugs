extends Control

func _ready() -> void:
	%PlayButton.pressed.connect(Transitions.change_scene_with_transition.bind(ProjectSettings.get_setting("application/run/main_scene")))
