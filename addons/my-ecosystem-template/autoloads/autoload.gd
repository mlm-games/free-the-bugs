## Should be set as the autoload by default
extends Node

static var tree : SceneTree

static var elapsed_time := 0


func _ready():
	tree = get_tree()
	var timer = Timer.new()
	timer.one_shot = false
	timer.wait_time = 1
	tree.root.add_child.call_deferred(timer)
	timer.start.call_deferred()
	timer.timeout.connect(func(): elapsed_time+=1)
