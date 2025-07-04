## A collection of static functions for creating screen-wide visual effects.
##[br][br]
## Provides easy-to-use methods for common "juice" effects like camera shake,
## shader pulses, and impact flashes. All functions are static and can be
## called directly from the [code]ScreenEffects[/code] class without needing
## to instantiate it.
class_name ScreenEffects
extends RefCounted


## Shakes a [Camera2D] node with random offsets that decay over a set duration.
##[br][br]
## This is useful for adding impact to events like explosions or taking damage.
##[br]
## It works by creating a [Tween] that rapidly changes the camera's [member Camera2D.offset].
##[br]
## [param camera]: The [Camera2D] node to shake.
##[br]
## [param strength]: The maximum offset in pixels for the shake.
##[br]
## [param duration]: The total time in seconds the effect should last.
static func shake_camera(camera: Camera2D, strength: float = 10.0, duration: float = 0.2) -> void:
	var tween = camera.create_tween()
	var shake_count = int(duration * 60) # 60 shakes per second
	
	for i in shake_count:
		var decay = 1.0 - (float(i) / shake_count)
		var offset = Vector2(
			randf_range(-strength, strength) * decay,
			randf_range(-strength, strength) * decay
		)
		tween.tween_property(camera, "offset", offset, 1.0/60.0)
	
	tween.tween_property(camera, "offset", Vector2.ZERO, 1.0/60.0)


## Creates a brief chromatic aberration "pulse" effect using a shader.
##[br][br]
## [b]Setup Required:[/b] This function requires a [CanvasLayer] in your scene containing
## a [ColorRect] that fills the screen. This [ColorRect] must have a [ShaderMaterial]
## attached, with its shader set to [code]res://shaders/chromatic_aberration.gdshader[/code].
##[br][br]
## [param shader_material]: The [ShaderMaterial] containing the chromatic aberration shader.
##[br]
## [param duration]: The total time in seconds for the pulse.
##[br]
## [param strength]: The maximum strength of the color separation effect.
static func chromatic_aberration_pulse(shader_material: ShaderMaterial, duration: float = 0.3, strength: float = 15.0) -> void:
	if not shader_material or not shader_material.shader:
		push_error("Chromatic Aberration: Invalid ShaderMaterial provided.")
		return

	var tween = shader_material.create_tween()
	tween.tween_property(shader_material, "shader_parameter/strength", strength, duration * 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(shader_material, "shader_parameter/strength", 0.0, duration * 0.7).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)


## Briefly flashes a [Node2D] or [Control] white to indicate a hit or interaction.
##[br][br]
## It automatically creates and assigns the required [ShaderMaterial] if the node
## does not already have one. Requires [code]res://shaders/flash_white.gdshader[/code].
##[br][br]
## [param node]: The [Node2D] or [Control] node to flash. The node must have a [member material] property.
##[br]
## [param duration]: The time in seconds for the flash to fade out.
static func flash_white(node: Node, duration: float = 0.1) -> void:
	if not node.has_method("get_material"):
		push_error("Node does not have a material property.")
		return
		
	var material = node.get_material()
	if not material is ShaderMaterial or not material.shader.resource_path.ends_with("flash_white.gdshader"):
		material = ShaderMaterial.new()
		material.shader = preload("uid://bf1q6g6cas62n")
		node.set_material(material)
	
	var tween = node.create_tween()
	tween.tween_method(func(value): material.set_shader_parameter("flash_amount", value), 1.0, 0.0, duration)


## Pauses the entire game for a very short duration to add impact to an event.
##[br][br]
## [color=yellow]Warning:[/color] This function uses [code]await[/code], so the calling function must be marked
## with [code]async[/code]. It globally changes [member Engine.time_scale], which affects
## all physics and animations in the game. Use with very short durations.
##[br][br]
## [param duration]: The time in seconds to freeze the game. Should be a small value like 0.05.
##[br][br]
## [codeblock lang=gdscript]
## async func _on_bullet_impact():
##     ScreenEffects.freeze_frame(0.08)
##     # ...spawn explosion, deal damage, etc.
## [/codeblock]
static func freeze_frame(duration: float = 0.05) -> void:
	Engine.time_scale = 0.0
	await Engine.get_main_loop().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1.0
