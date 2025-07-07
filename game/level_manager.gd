class_name LevelManager extends Node

static var instance : LevelManager

func _init() -> void:
	instance = self

signal start_level(level_data: LevelData)

@export var level_definitions: Array[LevelData] 

var current_level_index: int = -1

## Called from the menu to start the game from the first level.
func start_game():
	current_level_index = 0
	
	var level_instance = load(C.SCENE_PATHS.BASE_LEVEL_SCENE_PATH).instantiate()
	level_instance.level_data = level_definitions[current_level_index]
	Transitions.change_scene_with_transition_instance(level_instance)
	
	#start_level.emit(level_definitions[current_level_index])

## Called from the level scene when the player completes a level.
func advance_to_next_level():
	current_level_index += 1
	
	# Check if there are more levels left.
	if current_level_index < level_definitions.size():
		var next_level_data = level_definitions[current_level_index]
		start_level.emit(next_level_data)
	else:
		# We've finished the last level!
		game_completed()

## Called when the player finishes the final level.
func game_completed():
	print("All levels completed! Returning to menu.")
	current_level_index = -1
	Transitions.change_scene_with_transition(C.SCENE_PATHS.END_SCREEN_PATH)

func start_specific_level(index: int):
	if index >= 0 and index < level_definitions.size():
		current_level_index = index
		start_level.emit(level_definitions[current_level_index])
