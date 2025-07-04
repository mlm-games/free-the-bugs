## Should be set as the autoload by default
extends Node

static var tree : SceneTree

func _ready():
	tree = get_tree()
