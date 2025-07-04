extends Control

const HINT_PREFIX = "hint_"
var hint_name = self.get_script().get_path().split("/")[-1].trim_suffix(".gd")

enum State {DIALOGUE, EDITING, COMPLETED}

@onready var code_area: CodeEdit = %CodeArea
@onready var ans_area: CodeEdit = %AnsArea
@onready var hint_button: AnimButton = %HintButton

@onready var og_text = code_area.text
@onready var ans_text = ans_area.text

func  _ready() -> void:
	code_area.text_changed.connect(_on_code_changed)
	hint_button.pressed.connect(DialogueManager.show_dialogue_balloon.bind(preload("uid://br0g15mlkqp0p"), HINT_PREFIX + hint_name))
	
	DialogueManager.show_dialogue_balloon(preload("uid://bcyitiwfyenvi"), "start")
	
	

func _on_code_changed():
	if code_area.text == ans_area.text:
		print("Level completed")
