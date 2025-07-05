## Should be set as the autoload by default
extends Node

static var tree : SceneTree

static var elapsed_time := 0


func _ready():
	tree = get_tree()
	var timer = Timer.new()
	timer.one_shot = false
	tree.create_timer(1).timeout.connect(func(): elapsed_time+=1; print(elapsed_time))
