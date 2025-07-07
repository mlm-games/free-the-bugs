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
