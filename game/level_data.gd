class_name LevelData
extends Resource

## A unique identifier for this level, used for dialogue keys. e.g., "W1Level1"
@export var level_id: StringName

## The initial "buggy" code the player sees.
@export_multiline var initial_code: String

@export_multiline var answer_code: String

## The expected output to show when the code is correct.
@export var output_string: String

@export_multiline var initial_tip: String

## The tip to show after the player edits the code once.
@export_multiline var first_edit_tip: String

## The tip to show after the player edits after using a hint.
@export_multiline var after_hint_tip: String

## Set to false for levels that have no dialogue.
@export var show_dialogue: bool = true

@export var show_output_area := true

@export var show_hint_button := true
