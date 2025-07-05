extends Control

const HINT_PREFIX = "hint_"
var level_name = self.get_script().get_path().split("/")[-1].trim_suffix(".gd")

var edited_once := false
var hint_clicked := false
var edited_once_after_hint := false

enum State {DIALOGUE, EDITING, COMPLETED}

@export var hint_dialogue : DialogueResource
@export var level_dialogue : DialogueResource

@onready var code_area: CodeEdit = %CodeArea
@onready var ans_area: CodeEdit = %AnsArea
@onready var hint_button: AnimButton = %HintButton

@onready var og_text = code_area.text
@onready var ans_text = ans_area.text

func  _ready() -> void:
	code_area.text_changed.connect(_on_code_changed)
	hint_button.pressed.connect(func():
		DialogueManager.show_dialogue_balloon(hint_dialogue, HINT_PREFIX + level_name)
		hint_clicked = true
		)
	
	DialogueManager.show_dialogue_balloon(level_dialogue, "start")
	
	UIEffects.typewriter_effect(%TipLabel)

func _on_code_changed():
	if not edited_once:
		edited_once = true
		%TipLabel.text = "[wave]Ignore the [i]class void main[/i] part for now, thats just the boilerplate."
		UIEffects.typewriter_effect(%TipLabel)
	
	if hint_clicked and not edited_once_after_hint:
		%TipLabel.text = "[wave]The bug appears to be present in [i][b]line 3[/b][/i]."
		UIEffects.typewriter_effect(%TipLabel)
	
	
	if code_area.text == ans_area.text:
		print("Level completed")
		DialogueManager.show_dialogue_balloon(level_dialogue, level_name + "_end")
	
	
