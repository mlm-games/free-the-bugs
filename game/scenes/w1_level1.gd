extends Control

@onready var code_area: CodeEdit = %CodeArea
@onready var ans_area: CodeEdit = %AnsArea

@onready var og_text = code_area.text
@onready var ans_text = ans_area.text

func  _ready() -> void:
	
	DialogueManager.show_dialogue_balloon(preload("uid://bcyitiwfyenvi"), "start")
	
	code_area.text_changed.connect(_on_code_changed)

func _on_code_changed():
	if code_area.text == ans_area.text:
		print("Level completed")
