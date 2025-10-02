## Purpose: A persistent, global manager for playing common UI sounds.
## It uses a dedicated ObjectPool to handle multiple sound requests at once.
extends Node

# Sound Resources (cannot be configured in the inspector, as of 4.4, so set it later here)
@export var default_click_sound: AudioStream = preload("uid://ct0gmpjo3wc7l")
@export var default_hover_sound: AudioStream = preload("uid://dv2ll15jna4ww")

# Internal Player Pool
const POOL_SIZE = 5 # UI sounds are less frequent, so a smaller pool is fine
var _player_pool: ObjectPool

func _ready():
	# Create the pool for UI audio players
	var player_scene = PackedScene.new()
	player_scene.pack(AudioStreamPlayer.new())
	
	_player_pool = ObjectPool.new(player_scene, POOL_SIZE, POOL_SIZE) # max_size = initial_size
	_player_pool.name = "UIAudioPlayerPool"
	add_child(_player_pool)


# Public API

func play_click_sound():
	play_ui_sound(default_click_sound)

func play_hover_sound():
	play_ui_sound(default_hover_sound)

func play_ui_sound(stream: AudioStream):
	if not stream: return

	var player: AudioStreamPlayer = _player_pool.get_object()
	if not player: return # Pool exhausted, do nothing.

	player.stream = stream
	player.bus = &"Sfx" # UI sounds typically go to the Sfx bus
	player.play()
	
	# Release the player back to the pool when finished.
	#if player: player.finished.connect(_player_pool.release_object.bind(player), CONNECT_ONE_SHOT)
