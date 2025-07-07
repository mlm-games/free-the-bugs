extends Control

func _ready() -> void:
	%PlayButton.pressed.connect(Transitions.change_scene_with_transition.bind(ProjectSettings.get_setting("application/run/main_scene")))
	%TimeLabel.text += str(int(A.elapsed_time/60)) + " mins " + str(int(A.elapsed_time%60)) + " secs"
