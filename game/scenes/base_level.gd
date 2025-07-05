extends Control

const HINT_PREFIX = "Hint"

var edit_count := 0
var edited_once := false
@export var edited_once_tip : String
var hint_clicked := false
var edited_once_after_hint := false
@export var edited_once_after_hint_tip : String
@export var output_string : String

enum State {DIALOGUE, EDITING, COMPLETED}
@export var show_dialogue_for_level := true
@export var no_of_edits_to_show_next_tip: int = 3
@export var no_of_edits_to_show_next_tip_after_hint := 6

@export var hint_dialogue : DialogueResource
@export var level_dialogue : DialogueResource
@export var next_scene : PackedScene

@onready var level_name = Engine.get_main_loop().current_scene.name

@onready var code_area: CodeEdit = %CodeArea
@onready var ans_area: CodeEdit = %AnsArea
@onready var hint_button: AnimButton = %HintButton

@onready var og_text = code_area.text
@onready var ans_text = ans_area.text

func  _ready() -> void:
	code_area.text_changed.connect(_on_code_changed)
	hint_button.pressed.connect(func():
		if show_dialogue_for_level: DialogueManager.show_dialogue_balloon(hint_dialogue, level_name + HINT_PREFIX)
		hint_clicked = true
		)
	
	if show_dialogue_for_level: DialogueManager.show_dialogue_balloon(level_dialogue, level_name + "Start")
	
	UIEffects.typewriter_effect(%TipLabel)

func _on_code_changed():
	if not edited_once:
		edited_once = true
		%TipLabel.text = edited_once_tip
		UIEffects.typewriter_effect(%TipLabel)
	
	if hint_clicked and not edited_once_after_hint:
		edited_once_after_hint = true
		%TipLabel.text = edited_once_after_hint_tip
		UIEffects.typewriter_effect(%TipLabel)
	
	
	if code_area.text == ans_area.text:
		%OutputArea.text = output_string
		print("Level completed")
		if show_dialogue_for_level:
			DialogueManager.show_dialogue_balloon(level_dialogue, level_name + "End")
			await DialogueManager.dialogue_ended
		Transitions.change_scene_with_transition_packed(next_scene)
	
	
