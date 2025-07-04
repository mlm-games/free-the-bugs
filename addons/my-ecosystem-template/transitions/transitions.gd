extends CanvasLayer

signal screen_covered

#const CIRCLE_SHADER = preload("uid://dnms5hsmipkyv")

@onready var transition_player: AnimationPlayer = $TransitionRect/TransitionPlayer
@onready var transition_rect : ColorRect = $TransitionRect
@onready var white_rect : ColorRect = $OnScreenEffectsRect
@onready var effects_player: AnimationPlayer = $OnScreenEffectsRect/EffectsPlayer
@onready var shader_rect: ColorRect = $ShaderRect

var single_transition : bool

func _ready() -> void:
	transition_rect.visible = false
	white_rect.visible = false
	shader_rect.visible = false

func change_scene_with_transition(scene_path: String, anim_name: String = "fadeToBlack", pop_up: bool = false) -> void:
	transition(anim_name)
	await screen_covered
	if !pop_up:
			get_tree().change_scene_to_file(scene_path)

func change_scene_with_transition_packed(scene: PackedScene, anim_name: String = "fadeToBlack") -> void:
	transition(anim_name)
	await screen_covered
	get_tree().change_scene_to_packed(scene)

func transition(anim_name: StringName = "fadeToBlack", single_transition_only: bool = false, speed_scale: float = 1, pop_up: bool = false) -> void:
	if single_transition_only:
			single_transition = true
	match anim_name:
			"fadeToBlack":
					transition_player.speed_scale = speed_scale
					transition_rect.material = ShaderMaterial.new()
					transition_rect.visible = true
					transition_player.play(anim_name)
			"slightFlash":
					transition_player.speed_scale = speed_scale
					white_rect.visible = true
					transition_player.play(anim_name)
			"circleIn":
					transition_player.speed_scale = speed_scale
					#transition_rect.material.shader = CIRCLE_SHADER
					transition_rect.modulate = Color.WHITE
					transition_rect.visible = true
					transition_player.play(anim_name)
			"circleOut":
					transition_player.speed_scale = speed_scale
					#transition_rect.material.shader = CIRCLE_SHADER
					transition_rect.visible = true
					transition_rect.modulate = Color.WHITE
					transition_player.play(anim_name)
	if pop_up:
			pass



func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !single_transition:
		match anim_name:
				"fadeToBlack":
						screen_covered.emit()
						transition_player.play("fadeToNormal")
				"fadeToNormal":
						transition_rect.hide()
				"slightFlash":
						white_rect.hide()
				"circleIn":
						screen_covered.emit()
						transition_player.play("circleOut")
				"circleOut":
						transition_rect.hide()
	single_transition = false

func _input(_event: InputEvent) -> void:
	if transition_player.is_playing():
			get_viewport().set_input_as_handled()


## Need to be in an autoload to work. (or have a refernce to the scenetree)
#hack: insert no of cycles formula/ use frequency instead of duration for another function called smooth screen shake?
func screen_shake(duration: float, amplitude: float, camera: Camera2D = get_viewport().get_camera_2d()) -> void:
	var tween : Tween = create_tween()
	var original_position : Vector2 = camera.position
	for i in range(int(duration * 60)):  # Assuming 60 FPS
		var camera_offset : Vector2 = Vector2(randf() * amplitude * 2 - amplitude, 0)
		tween.tween_property(camera, "position", original_position + camera_offset, 1.0 / 60)  # Tween for 1 frame
	tween.tween_property(camera, "position", original_position, 1.0 / 60)  # Return to original position


func camera_shake(intensity: float = 1.5, duration: float = 1.5, decay: float = 3.0, camera: Camera2D = get_viewport().get_camera_2d()) -> void:
	# Stop any existing shake tweens
	if camera.has_meta("shake_tween") and camera.get_meta("shake_tween").is_valid():
			camera.get_meta("shake_tween").kill()
	
	var tween : Tween = create_tween()
	camera.set_meta("shake_tween", tween)
	
	var original_position := camera.position
	var original_rotation := camera.rotation
	
	# This will be called by tween_method to update the camera shake
	var shake_function := func(progress: float) -> void:
		var remaining := 1.0 - progress
		var current_intensity := intensity * pow(remaining, decay)
		
		if current_intensity > 0.01:
			var cam_offset := Vector2(
				intensity * 5.0 * current_intensity * randf_range(-1, 1),
				intensity * 5.0 * current_intensity * randf_range(-1, 1)
			)
			var cam_rotation := 0.1 * intensity * current_intensity * randf_range(-1, 1)
			
			camera.position = original_position + cam_offset
			camera.rotation = original_rotation + cam_rotation
		else:
			camera.position = original_position
			camera.rotation = original_rotation
	
	#call our shake function over the duration
	tween.tween_method(shake_function, 0.0, 1.0, duration)
	
	# Reset camera when done
	tween.tween_callback(func() -> void:
		camera.position = original_position
		camera.rotation = original_rotation
	)

func squash_simple(target: Object, x_force: float, y_force: float, duration: float = 0.3, trans_type: Tween.TransitionType = Tween.TRANS_QUAD, ) -> void:
	var tween : Tween = create_tween()
	# initial squash
	tween.tween_property(target, "scale:x", 1 - x_force, duration/2).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(target, "scale:y", 1 + y_force, duration/2).set_trans(trans_type).set_ease(Tween.EASE_OUT)
	# return to normal
	tween.tween_property(target, "scale:x", 1, duration/2).set_trans(trans_type).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(target, "scale:y", 1, duration/2).set_trans(trans_type).set_ease(Tween.EASE_IN)
