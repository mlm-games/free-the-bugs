extends Control

@export var level_data: LevelData

@onready var code_area: CodeEdit = %CodeArea
@onready var ans_area: CodeEdit = %AnsArea
@onready var hint_button: AnimButton = %HintButton
@onready var tip_label: RichTextLabel = %TipLabel
@onready var output_area: CodeEdit = %OutputArea

@export var hint_dialogue : DialogueResource
@export var level_dialogue : DialogueResource

var edit_count := 0
var edited_once := false
var hint_clicked := false
var edited_once_after_hint := false

func _ready() -> void:
	LevelManager.instance.start_level.connect(_on_start_level)
	
	if not is_instance_of(level_data, LevelData):
		push_error("No LevelData resource assigned to this level scene!")
		return
	
	setup_or_reset_level()
	
	code_area.text_changed.connect(_on_code_changed)
	hint_button.pressed.connect(_on_hint_pressed)
	
	_apply_layout()
	


func _wire_responsive_layout() -> void:
	# Re-apply layout on rotation/resize
	get_viewport().size_changed.connect(_apply_layout)
	_apply_layout.call_deferred()

func _apply_layout() -> void:
	var s := get_viewport().get_visible_rect().size
	var portrait := s.y >= s.x

	if portrait:
		_layout_portrait()
	else:
		_layout_landscape()

func _rect_percent(ctrl: Control, l: float, t: float, r: float, b: float, margin := 12.0) -> void:
	ctrl.anchor_left = l;   ctrl.anchor_top = t
	ctrl.anchor_right = r;  ctrl.anchor_bottom = b
	ctrl.offset_left = margin
	ctrl.offset_top = margin
	ctrl.offset_right = -margin
	ctrl.offset_bottom = -margin

func _layout_portrait() -> void:
	# CodeArea - top ~55%
	_rect_percent(code_area, 0.0, 0.0, 1.0, 0.55)

	# OutputArea - sits below
	if is_instance_valid(output_area):
		_rect_percent(output_area, 0.0, 0.55, 1.0, 0.82)

	# TipLabel - bottom band
	_rect_percent(tip_label, 0.0, 0.82, 1.0, 0.92, 8.0)

	# Hint button - bottom-right
	hint_button.anchor_left = 1.0
	hint_button.anchor_right = 1.0
	hint_button.anchor_top = 1.0
	hint_button.anchor_bottom = 1.0
	hint_button.offset_left = -150
	hint_button.offset_right = -20
	hint_button.offset_top = -120
	hint_button.offset_bottom = -40
	

func _layout_landscape() -> void:
	# CodeArea - left column
	_rect_percent(code_area, 0.02, 0.05, 0.64, 0.93)

	# OutputArea upper-right
	if is_instance_valid(output_area):
		_rect_percent(output_area, 0.66, 0.05, 0.98, 0.60)

	_rect_percent(tip_label, 0.02, 0.93, 0.98, 1.0, 8.0)

	# Hint button bottom-right
	hint_button.anchor_left = 1.0
	hint_button.anchor_right = 1.0
	hint_button.anchor_top = 1.0
	hint_button.anchor_bottom = 1.0
	hint_button.offset_left = -140
	hint_button.offset_right = -25
	hint_button.offset_top = -110
	hint_button.offset_bottom = -30

func _on_start_level(new_level_data: LevelData):
	var next_level_instance = load(C.SCENE_PATHS.BASE_LEVEL_SCENE_PATH).instantiate()
	next_level_instance.level_data = new_level_data
	Transitions.change_scene_with_transition_instance(next_level_instance)

func setup_or_reset_level():
	code_area.text = level_data.initial_code
	tip_label.text = level_data.initial_tip
	output_area.text = ""
	
	if !level_data.show_output_area: output_area.hide()
	if !level_data.show_hint_button: hint_button.hide()
	
	edit_count = 0
	edited_once = false
	hint_clicked = false
	edited_once_after_hint = false
	
	if level_data.show_dialogue:
		DialogueManager.show_dialogue_balloon(level_dialogue, str(level_data.level_id) + "Start")

func _on_code_changed():
	edit_count += 1
	UiAudioM.play_ui_sound(C.KeypressSound)
	
	if not edited_once:
		edited_once = true
		tip_label.text = level_data.first_edit_tip
		UIEffects.typewriter_effect(tip_label)
	
	if hint_clicked and not edited_once_after_hint and level_data.show_dialogue:
		edited_once_after_hint = true
		tip_label.text = level_data.after_hint_tip
		UIEffects.typewriter_effect(tip_label)
	
	if verify_code():
		complete_level()

func _on_hint_pressed():
	#if level_data.show_dialogue:
	DialogueManager.show_dialogue_balloon(hint_dialogue, str(level_data.level_id) + "Hint")
	hint_clicked = true

func complete_level():
	print("Level completed: " + str(level_data.level_id))
	output_area.text = level_data.output_string
	
	if level_data.show_dialogue:
		DialogueManager.show_dialogue_balloon(level_dialogue, str(level_data.level_id) + "End")
		await DialogueManager.dialogue_ended
	
	LevelManager.instance.advance_to_next_level()

func verify_code() -> bool:
	var player_code_normalized = Utils.normalize(code_area.text)
	var answer_code_normalized = Utils.normalize(level_data.answer_code)
	
	return player_code_normalized == answer_code_normalized
